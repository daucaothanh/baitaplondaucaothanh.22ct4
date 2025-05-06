from robot.api.deco import keyword
import easyocr
import os

reader = easyocr.Reader(['en'])

@keyword("Đọc Mã Captcha")
def read_captcha(path='captcha.png'):
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), path) 
    results = reader.readtext(path)
    if results:
        best_match = max(results, key=lambda r: r[2])
        return best_match[1].strip()
    return ""