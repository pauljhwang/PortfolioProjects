-- Cleaning Data in SQL Queries

Select *
From dbo.HousingData

-- Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.HousingData a
JOIN dbo.HousingData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.HousingData a
JOIN dbo.HousingData b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-- Breaking out Address into Individual Colummns (Address, City, State)

-- First with PropertyAddress using Substring

Select PropertyAddress
From dbo.HousingData

Select 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From dbo.HousingData

ALTER TABLE HousingData
Add PropertySplitAddress NVARCHAR(255)

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE HousingData
Add PropertySplitCity NVARCHAR(255)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

-- Now with OwnerAdddress using Parsename

Select OwnerAddress
From dbo.HousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From dbo.HousingData

ALTER TABLE HousingData
Add OwnerSplitAddress NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE HousingData
Add OwnerSplitCity NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE HousingData
Add OwnerSplitState NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold in Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.HousingData
Group by SoldasVacant
Order by 2

Select SoldAsVacant,
    CASE When SoldAsVacant = 'Y' THEN 'Yes'
         When SoldAsVacant = 'N' THEN 'No'
         Else SoldAsVacant
         END
From dbo.HousingData

Update dbo.HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
         When SoldAsVacant = 'N' THEN 'No'
         Else SoldAsVacant
         END


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                    UniqueID
                    ) row_num
From dbo.HousingData
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns

Select *
From dbo.HousingData

ALTER TABLE dbo.HousingData
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE dbo.HousingData
DROP COLUMN SaleDate