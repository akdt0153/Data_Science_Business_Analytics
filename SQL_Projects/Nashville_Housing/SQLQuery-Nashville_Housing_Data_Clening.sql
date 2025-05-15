/*

Cleaning Data In SQL Queries

*/

select * from
PortfolioProjects.dbo.NashvilleHousing

----------------------------------------------------------

--Standardize Date Format

select sale_date,CONVERT(Date,saledate) from
PortfolioProjects.dbo.NashvilleHousing

update Nashvillehousing
set saledate=CONVERT(Date,saledate)

Alter table NashvilleHousing
add Sale_Date date

update Nashvillehousing
set Sale_Date=CONVERT(Date,saledate)


-----------------------------------------------------------
--Populate Property Address Data

select *
from PortfolioProjects.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelId,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
join PortfolioProjects.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.uniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
join PortfolioProjects.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.uniqueID <> b.UniqueID
where a.PropertyAddress is null




-----------------------------------------------------------------------

--Breaking Out Address Into Idividual Columns (Address,City,State)


select PropertyAddress
from PortfolioProjects.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress) +1,len(PropertyAddress)) as Address

from PortfolioProjects.dbo.NashvilleHousing


alter table NashvilleHousing
add Property_Address nvarchar(255)

update NashvilleHousing
set Property_Address = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)


alter table NashvilleHousing
add Property_City nvarchar(255)

update NashvilleHousing
set Property_City = substring(PropertyAddress,charindex(',',PropertyAddress) +1,len(PropertyAddress))

select *
from PortfolioProjects.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProjects.dbo.NashvilleHousing

select 
parsename(Replace(OwnerAddress,',','.'),3),
parsename(replace(ownerAddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from PortfolioProjects.dbo.NashvilleHousing


alter table NashvilleHousing
add Owner_Address nvarchar(255)

update NashvilleHousing
set Owner_Address =parsename(Replace(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add Owner_City nvarchar(255)

update NashvilleHousing
set Owner_City = parsename(replace(ownerAddress,',','.'),2)

alter table NashvilleHousing
add Owner_State nvarchar(255)

update NashvilleHousing
set Owner_State = parsename(replace(ownerAddress,',','.'),1)



-----------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold As Vacant' Field

select distinct(soldasvacant),Count(soldasvacant)
from PortfolioProjects.dbo.NashvilleHousing
group by soldasvacant
order by 2


select SoldasVacant,
  case when Soldasvacant='Y' then  'Yes'
       when Soldasvacant = 'N' then 'No'
	   Else Soldasvacant
	   END
from PortfolioProjects.dbo.NashvilleHousing


Update NashvilleHousing
set SoldAsVacant =  case when Soldasvacant='Y' then  'Yes'
       when Soldasvacant = 'N' then 'No'
	   Else Soldasvacant
	   END


-----------------------------------------------------------------------------------------

--Removing Duplicates

With Row_Num_CTE as(
select *,
    row_number() over(
	partition by parcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) Row_Num
from PortfolioProjects.dbo.NashvilleHousing
--order by ParcelID
)
select * 
from Row_Num_CTE
where Row_Num >1
order by PropertyAddress


With Row_Num_CTE as(
select *,
    row_number() over(
	partition by parcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) Row_Num
from PortfolioProjects.dbo.NashvilleHousing
--order by ParcelID
)
delete 
from Row_Num_CTE
where Row_Num >1



--------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProjects.dbo.NashvilleHousing

alter table PortfolioProjects.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table PortfolioProjects.dbo.NashvilleHousing
drop column saledate


