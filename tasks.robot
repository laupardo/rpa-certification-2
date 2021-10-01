*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF r\\\\\\\\\eceipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.FileSystem
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault


*** Keywords ***
Open the robot order website
    Add Text  Please write the url for ordering robots
    Add text input    robot_url
    ${result}=  Run dialog
    Open Available Browser  ${result.robot_url}
Get orders
    Download    ${ORDERS_URL}  overwrite=True
    ${orders}=  Read table from CSV    orders.csv
Close the annoying modal
  Click Element  xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[3]
Fill the form    
    [Arguments]  ${row}
    Select From List By Value    id:head    ${row}[Head]
    Click Element  id:id-body-${row}[Body]
    ${id}=  Get Element Attribute  xpath://*[@id="root"]/div/div[1]/div/div[1]/form/div[3]/label  for
    Input Text  id:${id}  ${row}[Legs]
    Input Text  id:address  ${row}[Address]
Preview the robot
    Click Button  id:preview
Submit the order
    Click Button  id:order
    Wait Until Element Is Visible    id:receipt 
Store the receipt as a PDF file
    [Arguments]  ${name}
    Wait Until Element Is Visible    id:receipt 
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    ${pdf}=  Html To Pdf    ${receipt_html}    ${CURDIR}${/}output${/}pdfs${/}${name}.pdf
Take a screenshot of the robot and embed    
    [Arguments]  ${name}   
    Screenshot  locator=id:robot-preview-image  filename=${name}.png
    ${sclist}=  Create List  ${CURDIR}${/}output${/}pdfs${/}${name}.pdf  ${CURDIR}${/}${name}.png  
    ${path}=   Convert To String  ${CURDIR}${/}output${/}pdfs${/}${name}.pdf
    Add Files To PDF   ${sclist}    ${path}
    Remove File  ${name}.png
Go to order another robot
    Click Button  id:order-another
Create a ZIP file of the receipts
    Archive Folder With Zip  ${CURDIR}${/}output${/}pdfs  ${CURDIR}${/}output${/}pdfs.zip
    #Move File    ${CURDIR}${/}pdfs.zip     ${CURDIR}${/}output${/}   overwrite=True
Get url and download orders
    ${ORDERS_URL}=    Get Secret    orders
    Download    ${ORDERS_URL}[url]  overwrite=True

*** Variables ***
#${ORDERS_URL}  https://robotsparebinindustries.com/orders.csv

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Get url and download orders
    ${orders}=  Read table from CSV    orders.csv
    FOR    ${row}    IN    @{orders}
       Close the annoying modal
       Fill the form  ${row}
       Preview the robot
       Wait Until Keyword Succeeds  7x  10ms  Submit the order
       Store the receipt as a PDF file    ${row}[Order number]
       Take a screenshot of the robot and embed    ${row}[Order number]
       Go to order another robot
     END
    Create a ZIP file of the receipts


