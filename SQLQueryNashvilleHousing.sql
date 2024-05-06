-- Project to Data clean and format NashvilleHousing database 



Select*
From NashvilleHousing..NashvilleHousing

-- Change sale date
-- currently date time format, we will be getting rid of the time portion

Select SaleDateConverted, Convert(date , SaleDate) as SoldDate
From NashvilleHousing..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date , SaleDate)

-- Add new permanentcolumn onto Nashvill housing data
Alter table NashvilleHousing
Add SaleDateConverted date;

-- Sets new column to "date" version of SaleDate

Update NashvilleHousing
Set SaleDateConverted = Convert(date , SaleDate)



-- Populate property address data

Select *
From NashvilleHousing..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- using parcel ID to to link to property address and populate null values in the column

-- Self join table to itself

Select a.ParcelID , a.PropertyAddress, b.ParcelID , b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress) as FillPropertyAdress
From NashvilleHousing..NashvilleHousing a
Join NashvilleHousing..NashvilleHousing b
-- When Parcel ID is same and unique ID is different populate property address
 On a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 -- Checks for null values in the column
 Where a.PropertyAddress is null


 -- updates the "a" table adress column to propertyy address from b table
 Update a
 Set PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
 From NashvilleHousing..NashvilleHousing a
Join NashvilleHousing..NashvilleHousing b
-- When Parcel ID is same and unique ID is different populate property address
 On a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null


 -- Breaking address into different columns
 --Using substring and Char Index (is the position of the character inputted)
 -- Substring shortens the string to the length charindex value where ut finds ',' minus 1 
Select a.PropertyAddress
From NashvilleHousing..NashvilleHousing a

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Town
From NashvilleHousing..NashvilleHousing a


-- Create two new permananet columns in Nashiville Housing

-- Adds column
Alter table NashvilleHousing
Add PropertyLine1 nvarchar(255);

--adds the line1 address into new column
Update NashvilleHousing
Set PropertyLine1 = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

-- Adds city column
Alter table NashvilleHousing
Add PropertyCity nvarchar(255);

-- Adds city address into new column
Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select *
From NashvilleHousing

-- Owner address splitting street, city,state 
-- Using Parc name

Select OwnerAddress
From NashvilleHousing

--PARSENAME ONLY USES PERIOD'.' not commas','
Select PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerStreet Nvarchar(255), OwnerCity Nvarchar(255), OwnerState Nvarchar(255);

Update NashvilleHousing
Set OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3), 
OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From NashvilleHousing




--Change Y and N to Yes and No in "sold as Vacant" field
-- Using case statements
Select Distinct(SoldAsVacant),count(soldASvacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Changing Y/nN to Yes and No using Case statements
Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant 
	END
	From NashvilleHousing

	Update NashvilleHousing
	Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant 
	END

-- remove duplicates
--Where is a windows function and does not work therefore a CTE is used
--Where row_num > 1

With RowNumCTE as (

Select*,ROW_NUMBER () OVER ( PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
From NashvilleHousing)
--ORDER BY ParcelID

--DELETE
Select*
From RowNumCTE
WHERE row_num > 1



--remove unused columns
Select*
FROM NashvilleHousing

Alter table NashvilleHousing

Drop COLUMN OwnerAddress , TaxDistrict, PropertyAddress 

Alter table NashvilleHousing
Drop COLUMN SaleDate