*** Settings ***
Library    SeleniumLibrary    run_on_failure=NOTHING
Library    SeleniumLibrary
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

        ${text}=    Đọc Mã Captcha    captcha.png
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
