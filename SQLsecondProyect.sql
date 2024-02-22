/*
Cleaning Data in SQL Queries

*/


Select *
From  PortfolioProyect.dbo.Nashville


--------------------------------------------------------------------------------------------------------------

-- Standardize Date Format



Select SaleDateConverted,CONVERT(Date,SaleDate)
From  PortfolioProyect.dbo.Nashville

UPDATE Nashville
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProyect..Nashville
Add SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)



-----------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From  PortfolioProyect.dbo.Nashville
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From  PortfolioProyect.dbo.Nashville a
join  PortfolioProyect.dbo.Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From  PortfolioProyect.dbo.Nashville a
join  PortfolioProyect.dbo.Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------


-- Breaking out Adress Into Individual Columns(Address,City,State)

Select PropertyAddress
From  PortfolioProyect.dbo.Nashville
--Where PropertyAddress is null
--order by PropertyAddress

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) as Address
From  PortfolioProyect.dbo.Nashville

ALTER TABLE PortfolioProyect..Nashville
Add PropertySplitAddress Nvarchar(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE PortfolioProyect..Nashville
Add PropertySplitCity Nvarchar(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))

Select OwnerAddress
From  PortfolioProyect.dbo.Nashville


Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From  PortfolioProyect.dbo.Nashville

ALTER TABLE PortfolioProyect..Nashville
Add OwnerSplitAdress Nvarchar(255);

UPDATE Nashville
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProyect..Nashville
Add OwnerSplitCity Nvarchar(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE PortfolioProyect..Nashville
Add OwnerSplitState Nvarchar(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)





----------------------------------------------------------------------------------------------------

--Change y and N yo Yes and No in "Solid as Vacant" Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProyect..Nashville
Group by SoldAsVacant
order by 2


Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProyect..Nashville

--Updating table with new replaces
UPDATE Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


---------------------------------------------------------------------------------------------------------

--Removing Duplicates
WITH RowNumCTE AS(
Select * ,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
		   PropertyAddress,
		   SalePrice,
		   SaleDate,
		   LegalReference
		   order by 
		   UniqueID
   )row_num
From PortfolioProyect..Nashville
)



--delete  
--From RowNumCTE
--Where row_num>1
--order by PropertyAddress
Select *  
From RowNumCTE
Where row_num>1
order by PropertyAddress




-----------------------------------------------------------------------------------

--Delete Unused Columns

select * 
From PortfolioProyect..Nashville

ALTER TABLE PortfolioProyect..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProyect..Nashville
DROP COLUMN SaleDate