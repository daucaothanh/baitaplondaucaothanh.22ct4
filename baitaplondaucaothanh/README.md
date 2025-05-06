*# Auto Check Violation for Vehicles

## **Mô tả**
Kịch bản này tự động tra cứu các lỗi vi phạm giao thông (phạt nguội) trên trang [CSGT](https://www.csgt.vn/tra-cuu-phuong-tien-vi-pham.html) với số biển số xe và loại xe cụ thể.

Kịch bản bao gồm các bước chính:
1. Mở trang web và nhập thông tin biển số xe.
2. Xử lý CAPTCHA bằng cách chụp ảnh và đọc mã (sử dụng script `captcha.py`).
3. Kiểm tra kết quả và thực hiện lại nếu CAPTCHA sai.
4. Đóng trình duyệt sau khi hoàn tất.

---

## **Yêu cầu hệ thống**
- **Python**: Phiên bản 3.8 hoặc cao hơn.
- Các thư viện cần thiết:
  - `selenium`
  - `schedule`
  - `pillow` (nếu dùng xử lý ảnh CAPTCHA)
  - `requests`

---

## **Hướng dẫn cài đặt**

### **1. Clone repository**
Tải mã nguồn từ repository (nếu có):
```bash
git clone <link-repo>
cd <ten-folder>
```

### **2. Cài đặt các thư viện cần thiết**
Cài đặt các thư viện phụ thuộc bằng lệnh:
```bash
pip install -r requirements.txt
```

### **3. Cấu hình kịch bản**

Mở file kịch bản `*.robot` và chỉnh sửa các biến trong phần `*** Variables ***`:
- `biensoxe`: Nhập biển số xe bạn muốn kiểm tra.
- `loaixesudung`: Chọn loại xe (ví dụ: "Ô tô" hoặc "Xe máy").

Đảm bảo file `captcha.py` được thiết kế để giải mã CAPTCHA phù hợp.

Ví dụ, nội dung file `captcha.py` có thể như sau:
```python
from PIL import Image
import pytesseract

def read_captcha(image_path):
    """Đọc mã CAPTCHA từ ảnh"""
    image = Image.open(image_path)
    text = pytesseract.image_to_string(image, config='--psm 7')
    return text.strip()
```

### **4. Chạy kịch bản**
Chạy file Robot Framework:
```bash
robot <filename>.robot
```

---

## **Ghi chú**
- Để xử lý CAPTCHA, bạn cần viết hoặc sử dụng script `captcha.py`. Nếu CAPTCHA phức tạp, có thể cần tích hợp dịch vụ bên thứ ba như `2Captcha`.
- Thử nghiệm giới hạn số lần nhập CAPTCHA sai để tránh bị chặn IP.
- CAPTCHA có thể thay đổi theo thời gian, dẫn đến việc kịch bản cần cập nhật.

---

## **Cấu trúc file Robot Framework**

### **File `auto_check_violation.robot`**
```robot
*** Settings ***
Library    SeleniumLibrary    run_on_failure=NOTHING
Library    captcha.py

*** Variables ***

${url}          https://www.csgt.vn/tra-cuu-phuong-tien-vi-pham.html
${trinhduyetweb}   Chrome
${biensoxe}       99F-006.76
${loaixesudung}       Ô tô

*** Test Cases ***

Chuong Trinh Phat Nguoi
    Open Browser    ${url}    ${trinhduyetweb}
    Maximize Browser Window

    ${loisai}=    Set Variable    True
    ${bientam}=     Set Variable    1

    WHILE    '${loisai}' == 'True' and ${bientam} <= 100
        Wait Until Element Is Visible    //input[@name="BienKiemSoat"]    timeout=10s
        Input Text    //input[@name="BienKiemSoat"]    ${biensoxe}
        Select From List By Label    //select[@name="LoaiXe"]    ${loaixesudung}

        Wait Until Element Is Visible    //*[@id="imgCaptcha"]    timeout=20s
        ${captcha_element}=    Get WebElement    //*[@id="imgCaptcha"]
        Capture Element Screenshot    ${captcha_element}    captcha.png

        ${text}=    Read Captcha    captcha.png
        Log    CAPTCHA: ${text}    console=True
        Input Text    //input[@name="txt_captcha"]    ${text}
        Click Element    xpath://input[@class='btnTraCuu']
        Sleep    5s

        ${loisai}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//div[@class='xe_textloisai' and contains(text(), 'Mã xác nhận sai!')]

        Run Keyword If    '${loisai}' == 'True'    Log    Nhập mã CAPTCHA sai, thử lại lần ${bientam}    console=True
        Run Keyword If    '${loisai}' == 'True'    Reload Page
        Run Keyword If    '${loisai}' == 'True'    Sleep    2s

        ${bientam}=    Evaluate    ${bientam} + 1
    END

    Run Keyword If    '${loisai}' == 'False'     Log    Chúc mừng bạn tra cứu thành công    console=True
        Sleep    2s
        ${content}=    Get Text    xpath=//*[@id="bodyPrint123"]
        Log    Nội dung tra cứu của bạn: ${content}    console=True
    Close Browser
