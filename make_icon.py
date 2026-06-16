from PIL import Image

logo = Image.open('assets/images/logo.png').convert('RGBA')
canvas_size = 1024
canvas = Image.new('RGBA', (canvas_size, canvas_size), (255, 255, 255, 255))
logo_size = int(canvas_size * 0.65)
logo_resized = logo.resize((logo_size, logo_size), Image.LANCZOS)
offset = (canvas_size - logo_size) // 2
canvas.paste(logo_resized, (offset, offset), logo_resized)
canvas.save('assets/images/logo_icon.png', 'PNG')
print('OK')
