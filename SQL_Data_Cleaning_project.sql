-- cleaning Data in SQL Queries

select* from PortfolioProject.dbo.NashvileHousing;

--- *******************************************************************************************************************------

-- Standardize Data Format

select SaleDate 
from PortfolioProject.dbo.NashvileHousing;

update NashvileHousing
set SaleDate = convert(Date, SaleDate);

ALTER TABLE NashvileHousing ADD SaleDateConverted date;

update NashvileHousing
set SaleDateConverted = convert(Date, SaleDate);

select SaleDateConverted 
from PortfolioProject.dbo.NashvileHousing;

---***************************************************************************************************************---

-- Populate Property address data

select *
from PortfolioProject.dbo.NashvileHousing
--where PropertyAddress is null
order by ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

---**************************************************************************************************************---

-- Breaking out address into Individual columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvileHousing
--where PropertyAddress is null
--order by ParcelID

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvileHousing

-- need to create two different columns to have the Split Address and City

ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvileHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);


ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD PropertySplitCity  nvarchar(255);

update PortfolioProject.dbo.NashvileHousing
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));


select PropertySplitAddress, PropertySplitCity 
from PortfolioProject.dbo.NashvileHousing

-- Lets Fix OwnerAddress 

select OwnerAddress
from PortfolioProject.dbo.NashvileHousing;

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvileHousing;


-- need to create two different columns to have the Split Address, City  and  State for OwnerAddress

ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvileHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD OwnerSplitCity  nvarchar(255);

update PortfolioProject.dbo.NashvileHousing
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE PortfolioProject.dbo.NashvileHousing
ADD OwnerSplitState  nvarchar(255);

update PortfolioProject.dbo.NashvileHousing
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1);

select 
OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject.dbo.NashvileHousing;

--*******************************************************************************************************************---

-- Change Y and N  to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvileHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
CASE	When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END
from PortfolioProject.dbo.NashvileHousing

Update NashvileHousing
SET SoldAsVacant  = CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END


---**********************************************************************************************************************---

--Remove Duplicates

with RowNumCTE as(
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 order by 
					UniqueID
					) Row_num
from PortfolioProject.dbo.NashvileHousing
-- order by ParcelID
) 
Delete
from RowNumCTE
where Row_num > 1
--order by PropertyAddress

---*******************************************************************************************************************-----

-- Delete Unused Columns

select*
from PortfolioProject.dbo.NashvileHousing

ALTER TABLE PortfolioProject.dbo.NashvileHousing 
DROP COLUMN PropertyAddress, OwnerAddress, TaXDistrict

ALTER TABLE PortfolioProject.dbo.NashvileHousing 
DROP COLUMN SaleDate


