/* Cleaning Data In SQL Project*/

SELECT*
FROM PortfolioProject.dbo.HousingData

/*Standardize the date format*/

ALTER TABLE PortfolioProject.dbo.HousingData
ALTER COLUMN SaleDate date

/*
Cleaning the Property Adress Data

*/
--Nulls are Present in the Property Address so we will attempt to remove them
SELECT*
FROM PortfolioProject.dbo.HousingData
where PropertyAddress is null

/*While exploring the data set we find that there are instances that pacelID repeats 
and we can use this to potentially fill the null property address*/

SELECT*
FROM PortfolioProject.dbo.HousingData
order by parceliD

--Populating property address 
SELECT a.ParcelID, b.PropertyAddress, b.ParcelID
FROM PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

/*Next we want to seperate the address components
Seperate components by Address, City, State
The Delimeter is a "," 
*/

--Here we seperate the address from the city 
SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))as city
FROM PortfolioProject.dbo.HousingData

--Add in two extra columns to store the data that was split

ALTER TABLE PortfolioProject.dbo.HousingData
add SplitPropertyAddress NvarChar(255)


ALTER TABLE PortfolioProject.dbo.HousingData
add SplitPropertyCity NvarChar(255)


update PortfolioProject.dbo.HousingData
set SplitPropertyAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)


update PortfolioProject.dbo.HousingData
set SplitPropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Allows us to break the owner address up by using parsename to look for periods in the string. 
--Becuase the string has no periods we use replace to replace the commas with periods to allow parsename to work 
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.HousingData

--We add the columns where we will store the newly delimated data and update them with the data
ALTER TABLE PortfolioProject.dbo.HousingData
ADD SplitOwnerAddress NvarChar(255)

UPDATE PortfolioProject.dbo.HousingData
SET SplitOwnerAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD SplitOwnerCity NvarChar(255)

UPDATE PortfolioProject.dbo.HousingData
SET SplitOwnerCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD SplitOwnerState NvarChar(255)

UPDATE PortfolioProject.dbo.HousingData
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--In the sold as vacant we have some inconsistencies with the data
--We are only suppose to have Yes and No responses but we have Yes, No, Y, N as well
Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.HousingData
Group by SoldAsVacant

--Two ways of making making the correction 
--Down below is an example of both

--First Method
UPDATE PortfolioProject.dbo.HousingData
SET SoldAsVacant = 'No'
Where SoldAsVacant = 'N'

UPDATE PortfolioProject.dbo.HousingData
SET SoldAsVacant = 'Yes'
Where SoldAsVacant = 'Y'

--Second Method
UPDATE PortfolioProject.dbo.HousingData
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
