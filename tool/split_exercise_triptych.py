#!/usr/bin/env python3
"""Split a horizontal three-frame exercise render into individual PNG files."""

import argparse
from pathlib import Path

from PIL import Image


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("slug")
    args = parser.parse_args()

    image = Image.open(args.input).convert("RGB")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    labels = ("inicio", "bajada", "subida")
    boundaries = (0, image.width // 3, (image.width * 2) // 3, image.width)

    for index, label in enumerate(labels):
        frame = image.crop(
            (boundaries[index], 0, boundaries[index + 1], image.height)
        )
        side = max(frame.width, frame.height)
        canvas = Image.new("RGB", (side, side), (0, 255, 0))
        canvas.paste(
            frame,
            ((side - frame.width) // 2, (side - frame.height) // 2),
        )
        canvas.save(args.output_dir / f"{args.slug}_{label}_key.png")


if __name__ == "__main__":
    main()
