/*

Cleaning Data in SQL Queries

*/

select * from NashvilleHousing

--Standardize Date Format

select SaleDate, convert(date,saledate) from NashvilleHousing

update NashvilleHousing
set saledate = convert(date,saledate)

select saledate from NashvilleHousing --the update query did not work

--using the Alter Query

Alter Table NashvilleHousing
Add DateOfSale Date

update NashvilleHousing
set DateOfSale = convert(date,saledate)

select DateOfSale, convert(date,saledate) from NashvilleHousing


--Populate Property Address Data


select *
from NashvilleHousing --where PropertyAddress is null
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(A.PropertyAddress, B.PropertyAddress)
from NashvilleHousing A
join NashvilleHousing B
on A.ParcelID = B.ParcelID
and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
set A.PropertyAddress = isnull(A.PropertyAddress, B.PropertyAddress)
from NashvilleHousing A
join NashvilleHousing B
on A.ParcelID = B.ParcelID
and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as AddressStreet,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as AddressCity
from NashvilleHousing

Alter Table NashvilleHousing
Add PropertyStreetAddress Nvarchar(255)

Alter Table NashvilleHousing
Add PpropertyCityAddress Nvarchar(255)

Alter Table NashvilleHousing
Drop column PpropertyCityAddress --incorrect spelling

Alter Table NashvilleHousing
Add PropertyCityAddress Nvarchar(255)

Update NashvilleHousing
set PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashvilleHousing
set PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

select * from 
NashvilleHousing

select  OwnerAddress from 
NashvilleHousing


select parsename(replace(owneraddress, ',', '.'), 3)  as OwnerStreetAddress,
 parsename(replace(owneraddress, ',', '.'), 2)as OwnerCityAddress,
 parsename(replace(owneraddress, ',', '.'), 1) as OwnerStateAddress
from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerStreetAddress Nvarchar(255)

Update NashvilleHousing
set OwnerStreetAddress = parsename(replace(owneraddress, ',', '.'), 3) 

Alter Table NashvilleHousing
Add OwnerCityAddress Nvarchar(255)

Update NashvilleHousing
set OwnerCityAddress = parsename(replace(owneraddress, ',', '.'), 2) 

Alter Table NashvilleHousing
Add OwnerStateAddress Nvarchar(255)

Update NashvilleHousing
set OwnerStateAddress = parsename(replace(owneraddress, ',', '.'), 1) 

--Change Y and N to Yes and No in "sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing


Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--Remove Duplicates

select *, Row_Number() 
over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from NashvilleHousing
order by ParcelID


with RowNumCTE as --using CTE to create a temp table and query the CTE to extract rows where row_num > 2(Duplicates)
(
select *, Row_Number() 
over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress

--deleting rows where row_num > 2

with RowNumCTE as --using CTE to create a temp table and query the CTE to extract rows where row_num > 2(Duplicates)
(
select *, Row_Number() 
over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from NashvilleHousing
--order by ParcelID
)
delete from RowNumCTE
where row_num > 1
--order by PropertyAddress

--Delete Unused Columns

select * from NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


