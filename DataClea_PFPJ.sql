/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject_DataCleaning.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(saledate AS Date)

SELECT SaleDateConverted 
FROM NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.parcelID = b.parcelID 
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null
--order by ParcelID 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.parcelID = b.parcelID 
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 -- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress))-1), 
SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress))+2, LEN(propertyAddress)-CHARINDEX(',',PropertyAddress))
FROM PortfolioProject_DataCleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(255);


ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress))-1);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress))+2, LEN(propertyAddress)-CHARINDEX(',',PropertyAddress))


SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject_DataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreet Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject_DataCleaning.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHOusing
GROUP BY SoldAsVacant


SELECT SoldAsVacant, 
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
       CASE 
	   When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject_DataCleaning.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *
FROM (SELECT *, ROW_NUMBER() OVER (
                             PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
							 ORDER BY UniqueID
							 ) AS rownum
      FROM PortfolioProject_DataCleaning.dbo.NashvilleHousing) AS subquery
WHERE rownum > 1


DELETE subquery
FROM (SELECT *, ROW_NUMBER() OVER (
                             PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
							 ORDER BY UniqueID
							 ) AS rownum
      FROM PortfolioProject_DataCleaning.dbo.NashvilleHousing) AS subquery
WHERE rownum > 1

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject_DataCleaning.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

SELECT *
FROM PortfolioProject_DataCleaning.dbo.NashvilleHousing


