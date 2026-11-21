import sys
from pypdf import PdfWriter, Transformation
from pypdf.generic import RectangleObject

A4_W, A4_H = 595.276, 841.89
MM = 72.0 / 25.4

def fit(src, dst, margin_mm=10.0):
    m = margin_mm * MM
    writer = PdfWriter(clone_from=src)
    for page in writer.pages:
        mb = page.mediabox
        cb = page.cropbox
        x0 = float(max(float(mb.left), float(cb.left)))
        y0 = float(max(float(mb.bottom), float(cb.bottom)))
        x1 = float(min(float(mb.right), float(cb.right)))
        y1 = float(min(float(mb.top), float(cb.top)))
        w, h = x1 - x0, y1 - y0
        avail_w, avail_h = A4_W - 2 * m, A4_H - 2 * m
        s = min(avail_w / w, avail_h / h)
        dx = (A4_W - w * s) / 2.0 - x0 * s
        dy = (A4_H - h * s) / 2.0 - y0 * s
        page.add_transformation(Transformation().scale(s).translate(dx, dy))
        box = RectangleObject([0, 0, A4_W, A4_H])
        page.mediabox = box
        page.cropbox = box
        page.trimbox = box
        page.bleedbox = box
        page.artbox = box
        print(f"  pagina {w:.1f}x{h:.1f}pt -> scala {s*100:.1f}%  dx={dx:.1f} dy={dy:.1f}")
    with open(dst, "wb") as fh:
        writer.write(fh)

if __name__ == "__main__":
    fit(sys.argv[1], sys.argv[2], float(sys.argv[3]) if len(sys.argv) > 3 else 10.0)
