![UGrow_Logo_Standard](https://github.com/user-attachments/assets/aa18aba1-2937-497f-a61a-c856af7f2e91)
# U-Grow - Grade 12 IT Practical Assessment Task (PAT)
> NOTE: This program was my capstone project for high school IT. It is designed to be a proof of concept that showcases programming skills, rather than a functional online store. 

U-Grow is a Delphi-based desktop application designed to support environmentally conscious consumers and vendors by providing an offline platform for managing eco-friendly product sales.

The platform allows:
- Customers – to browse, filter, and purchase eco-friendly products, view order history, and manage payments.
- Sellers – to easily add, update, or remove products, manage orders, and record receipts.

## User Interface

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/3700768a-2a77-403d-bca1-de6e80b92bf6" height="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/993e160d-d8d7-4c2c-b1f9-9d9b4ba2c0c2" height="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/97c2efce-b0f0-4cc3-a8a4-1adefc18c63f" height="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/ad760df6-e7bc-4369-993c-42eafcdb6fa2" height="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/94c2e45f-83c9-46b5-a99b-f84fb248befb" height="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/3a93506e-c855-42cb-b71c-675b3ef10e56" height="250"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/e0e8306b-1e3b-47bb-8718-0f26c9067402" height="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/65ac3508-59cc-4e3c-9aeb-4ef62690e7ae" height="250"/></td>
  </tr>
</table>

## How to Run the Program

Follow these steps to run U-Grow on your computer:

1. **Ensure Prerequisites**
   - Make sure the program folder contains:
     - `UGrow.exe` (the main program file)
     - `UGrow_Database.mdb` (the database)
     - `Product_Images` folder with all product `.jpg` images
     - `Receipt.txt` and `Seller_Logins.txt` if using preloaded data
   - Confirm the system date format is set to `dd/mm/yyyy`.
   - Recommended screen resolution: 1080p (works down to 720p).

2. **Launch the Program**
   - Double-click `UGrow.exe`.
   - The login screen will appear.

## Login Details for Testing

**Customer Login:**  
- Email: admin@admin.com  
- Password: admin

**Seller Login:**  
- Username: admin  
- Password: admin



## Setting up the Program

- The database must be stored in the same folder as the program with the name: `UGrow_Database.mdb`. See the structure below.
- Product images added to the folder `Product_Images` must be `.jpg` files named using the **ProductID**. Optimal aspect ratio is 5:4.
- Receipts are stored in a text file named `Receipt.txt` in the same folder as the program.
- Seller logins must be added to `Seller_Logins.txt` using the format: `username#password` (max 128 characters for both).
- Set the computer's date format to `dd/mm/yyyy` to ensure receipt functionality.
- The program is designed for 1080p screens but works down to 720p. Other resolutions may affect usability.



## Format of Various IDs

- **CustomerID**: First letter of first name, first two letters of last name, three random digits (e.g. `JDO566`)
- **ProductID**: First three letters of product name, three random digits (e.g. `GRE568`)
- **OrderID**: `INV` followed by five random digits (e.g. `INV10000`)
- **OrderProdID**: Sequential auto number



## Database Structure

### Relationships
![image](https://github.com/user-attachments/assets/3aded4ea-c934-4052-ad4b-430b06738037)

#### tblCustomers

| Field Name         | Field Type | Field Size | Example            |
|--------------------|------------|------------|--------------------|
| CustomerID (PK)    | Short Text | 6          | JDO566             |
| FirstName          | Short Text | 30         | John               |
| LastName           | Short Text | 30         | Doe                |
| DateOfBirth        | Date/Time  | Short Date | 20/06/2000         |
| Email              | Short Text | 128        | john.doe@gmail.com |
| Password           | Short Text | 128        | Password123        |
| OutstandingBalance | Currency   | Double     | R999               |

#### tblOrders

| Field Name      | Field Type | Field Size | Example    |
|------------------|------------|------------|------------|
| OrderID (PK)     | Short Text | 8          | INV10000   |
| CustomerID (FK)  | Short Text | 6          | JDO566     |
| OrderDate        | Date/Time  | Short Date | 23/02/2023 |

#### tblProducts

| Field Name  | Field Type | Field Size | Example                      |
|-------------|------------|------------|------------------------------|
| ProductID (PK) | Short Text | 6          | GRE568                       |
| ProductName   | Short Text | 30         | Greenhouse Shelving          |
| UnitPrice     | Currency   | Double     | R999                         |
| Description   | Short Text | 250        | A large shelf...             |
| Stock         | Number     | Integer    | 10                           |

#### tblOrderProd

| Field Name      | Field Type | Field Size  | Example   |
|------------------|------------|-------------|-----------|
| OrderProdID (PK) | Auto Number| Long Integer| 1         |
| OrderID (FK)     | Short Text | 8           | INV10000  |
| ProductID (FK)   | Short Text | 6           | GRE568    |
| Quantity         | Number     | Integer     | 1         |



## Standard Images Used

### Icons

- `Icons\Bin_Icon.bmp`
- `Icons\Cart_Icon.bmp`
- `Icons\Close_Icon.bmp`
- `Icons\Hide_Password_Resized.bmp`
- `Icons\PlaceOrder_Icon.bmp`
- `Icons\Save_Icon.bmp`
- `Icons\Show_Password_Resized.bmp`
- `Icons\Back_Icon.bmp`
- `Icons\Balance_Icon.bmp`

### Decorative Images

- `Decorative_Images\Microgreens_Header.jpg`
- `Decorative_Images\UGrow_Logo_Standard.png`
- `Decorative_Images\Forest.jpeg`


## License

This project is protected by copyright. See [LICENSE.md](LICENSE.md) for full details.
