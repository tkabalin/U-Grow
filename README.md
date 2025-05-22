![UGrow_Logo_Standard](https://github.com/user-attachments/assets/aa18aba1-2937-497f-a61a-c856af7f2e91)
# U-Grow

**Thomas Kabalin**

Grade 12 IT Practical Assessment Task (PAT)
> NOTE: This program was my capstone project for high school IT. It is designed to be a proof of concept that showcases programming skills, rather than a functional online store. 


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
