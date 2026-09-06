import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import '../core/validation/app_validators.dart';
import '../models/app_user.dart';
import 'demo_auth_service.dart';

class FirebaseAuthService {
  static const _adminEmail = 'admin@live.cl';

  static Future<AppUser> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(
          rememberMe ? Persistence.LOCAL : Persistence.SESSION,
        );
      }
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('No se pudo iniciar sesión');
      }

      final reference = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
      var snapshot = await reference.get();

      if (!snapshot.exists &&
          firebaseUser.email?.toLowerCase() == _adminEmail) {
        await reference.set({
          'rut': '',
          'name': 'Administrador GYM',
          'role': 'admin',
          'isActive': true,
          'email': _adminEmail,
          'createdAt': FieldValue.serverTimestamp(),
        });
        snapshot = await reference.get();
      }

      final data = snapshot.data();
      if (data == null) {
        await FirebaseAuth.instance.signOut();
        throw const AuthException('El usuario no tiene un perfil configurado');
      }
      if (data['isActive'] == false) {
        await FirebaseAuth.instance.signOut();
        throw const AuthException('Usuario inactivo');
      }

      return AppUser(
        id: firebaseUser.uid,
        rut: (data['rut'] as String?) ?? '',
        name: (data['name'] as String?) ?? 'Usuario',
        role: data['role'] == 'admin' ? UserRole.admin : UserRole.student,
        isActive: data['isActive'] != false,
      );
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          throw const AuthException('Correo o contraseña incorrectos');
        case 'too-many-requests':
          throw const AuthException(
            'Demasiados intentos. Intenta nuevamente más tarde',
          );
        default:
          throw const AuthException('No se pudo iniciar sesión con Firebase');
      }
    }
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> sendPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!AppValidators.isValidEmail(normalizedEmail)) {
      throw const AuthException('Ingresa un correo válido');
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: normalizedEmail,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'too-many-requests') {
        throw const AuthException(
          'Demasiados intentos. Intenta nuevamente más tarde',
        );
      }
      throw const AuthException('No se pudo enviar el correo de recuperación');
    }
  }

  static Future<AppUser> registerStudent({
    required String rut,
    required String email,
    required String name,
    required String password,
    Future<void> Function(AppUser user)? persistProfile,
  }) async {
    final normalizedRut = DemoAuthService.normalizeRut(rut);
    final normalizedEmail = email.trim().toLowerCase();
    if (!DemoAuthService.isValidRut(normalizedRut)) {
      throw const AuthException('El RUT ingresado no es válido');
    }
    final existingRut = await FirebaseFirestore.instance
        .collection('students')
        .where('rut', isEqualTo: normalizedRut)
        .limit(1)
        .get();
    if (existingRut.docs.isNotEmpty) {
      throw const AuthException('Ya existe un alumno con ese RUT');
    }
    final secondaryApp = await Firebase.initializeApp(
      name: 'student-${DateTime.now().microsecondsSinceEpoch}',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      final credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('No se pudo crear la cuenta del alumno');
      }

      final user = AppUser(
        id: firebaseUser.uid,
        rut: normalizedRut,
        name: name,
        role: UserRole.student,
      );
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'rut': user.rut,
        'name': user.name,
        'role': 'student',
        'isActive': true,
        'email': normalizedEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });
      try {
        await persistProfile?.call(user);
      } catch (error) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .delete();
        await firebaseUser.delete();
        if (error is StateError && error.toString().contains('RUT')) {
          throw const AuthException('Ya existe un alumno con ese RUT');
        }
        rethrow;
      }
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: normalizedEmail,
        );
      } on FirebaseAuthException catch (error) {
        debugPrint('No se pudo enviar el correo de contraseña: ${error.code}');
      }
      return user;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        throw const AuthException('Ya existe un usuario con ese correo');
      }
      if (error.code == 'weak-password') {
        throw const AuthException('La contraseña temporal es muy corta');
      }
      throw const AuthException('No se pudo crear la cuenta del alumno');
    } finally {
      await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
      await secondaryApp.delete();
    }
  }
}
