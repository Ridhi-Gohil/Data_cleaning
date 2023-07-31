Select *
From HousingInfo

--handling negative values

Select SalePrice
From HousingInfo
where SalePrice < 0

--remove duplicate representations caused by inconsistent capitalization
SELECT DISTINCT upper(OwnerName) AS CleanedOwnerName
FROM HousingInfo;


-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From HousingInfo

--To add the new column in the table
ALTER TABLE HousingInfo
Add SaleDateConverted Date;

Update HousingInfo
SET SaleDateConverted = CONVERT(Date,SaleDate)

--to delete the existing column from the table

ALTER TABLE HousingInfo
DROP COLUMN SaleDate;


-- Populate Property Address data
Select *
From HousingInfo
Where PropertyAddress is null
order by ParcelID

/*self joining the table 
ISNULL(a.PropertyAddress,b.PropertyAddress) - checks if address in a is null and 
if it is null then it will update that address with the b.address.*/
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingInfo a
JOIN HousingInfo b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Updating the column in the table
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingInfo a
JOIN HousingInfo b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From HousingInfo

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , 
LEN(PropertyAddress)) as Address
From HousingInfo

--adding and updating address column of propertyaddress
ALTER TABLE HousingInfo
Add PropertySplitAddress Nvarchar(255);

Update HousingInfo
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Select PropertySplitAddress
From HousingInfo

--adding and updating city column
ALTER TABLE HousingInfo
Add PropertySplitCity Nvarchar(255);

Update HousingInfo
SET PropertySplitCity = 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select PropertySplitCity
From HousingInfo

Select *
From HousingInfo


--adding and updating address column of owneraddress
Select OwnerAddress
From HousingInfo


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From HousingInfo

ALTER TABLE HousingInfo
Add OwnerSplitAddress Nvarchar(255);

Update HousingInfo
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Select OwnerSplitAddress
From HousingInfo

ALTER TABLE HousingInfo
Add OwnerSplitCity Nvarchar(255);

Update HousingInfo
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Select OwnerSplitCity
From HousingInfo

ALTER TABLE HousingInfo
Add OwnerSplitState Nvarchar(255);

Update HousingInfo
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From HousingInfo


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingInfo
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From HousingInfo

Update HousingInfo
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From HousingInfo
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns
Select *
From HousingInfo

ALTER TABLE HousingInfo
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--remove leading and trailing spaces from a string
UPDATE HousingInfo
SET PropertySplitAddress = TRIM(PropertySplitAddress);


UPDATE HousingInfo
SET PropertySplitCity = TRIM(PropertySplitCity);

--To handle outliers and clean the data in the "YearBuilt" 
select YearBuilt from HousingInfo
WHERE YearBuilt < 0 OR YearBuilt > YEAR(GETDATE());

UPDATE HousingInfo
SET YearBuilt = NULL
WHERE YearBuilt < 0 OR YearBuilt > YEAR(GETDATE())

