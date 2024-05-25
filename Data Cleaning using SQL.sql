SELECT * 
FROM [dbo].[Nashville_Housing]
;


---Standardizing date format-----
SELECT SaleDate, CONVERT(date,saledate)
FROM [dbo].[Nashville_Housing];

Alter Table Nashville_Housing
ADD SalesDateconverted Date;

Update Nashville_Housing
set SalesDateconverted= CONVERT(date, saledate);

SELECT SalesDateconverted, CONVERT(date,saledate)
FROM [dbo].[Nashville_Housing];


---------Property Address 
SELECT PropertyAddress 
FROM [dbo].[Nashville_Housing]
where PropertyAddress is NULL
order by ParcelID;

-----checking for duplicate address with same parcelid
SELECT a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
FROM [dbo].[Nashville_Housing] a
JOIN [dbo].[Nashville_Housing] b
     ON a.ParcelID= b.ParcelID
     AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is NULL;

Update a
SET PropertyAddress= ISNULL(a.propertyAddress,b.PropertyAddress)
FROM [dbo].[Nashville_Housing] a
JOIN [dbo].[Nashville_Housing] b
     ON a.ParcelID= b.ParcelID
     AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is NULL;


----Breaking Adress into individual Columns
SELECT PropertyAddress 
FROM [dbo].[Nashville_Housing]
--where PropertyAddress is NULL
--order by ParcelID;

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
FROM Nashville_Housing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS Address
FROM Nashville_Housing

Alter Table Nashville_Housing
add PropertysplitAddress Nvarchar(255);

Update Nashville_Housing
Set PropertysplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

Alter Table Nashville_Housing
add PropertysplitCity Nvarchar(255);

select PropertyAddress, PropertySplitaddress,Propertysplitcity
from Nashville_Housing
;
--spiltting onwers address
select OwnerAddress
from Nashville_Housing

SELECT
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
from Nashville_Housing
where OwnerAddress is not null

Alter Table Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);
Update Nashville_Housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter Table Nashville_Housing
Add OwnerSplitCity Nvarchar(255);
Update Nashville_Housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table Nashville_Housing
Add OwnerSplitState Nvarchar(255);
Update Nashville_Housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select OwnerAddress,OwnerSplitState,OwnerSplitCity
From Nashville_Housing;

---- Replacing Y and N with yes and No in soldasvacant column(using case statement)
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant;

Select SoldAsVacant,
Case When SoldAsVacant='Y' Then 'Yes'
     When SoldAsVacant='N' Then 'No'
	 Else SoldAsVacant
	 End
From Nashville_Housing;

Update Nashville_Housing
Set SoldAsVacant =Case When SoldAsVacant='Y' Then 'Yes'
     When SoldAsVacant='N' Then 'No'
	 Else SoldAsVacant
	 End;
Select Distinct(SoldAsVacant )
From Nashville_Housing;

--Removing duplicate
WITH RownumCTE AS(
Select*,
Row_Number() Over (Partition By 
                              ParcelId,
							  PropertyAddress,
							  saledate,
							  saleprice,
							  LegalReference
      						  Order by 
							 PropertyAddress)row_num
FROM [dbo].[Nashville_Housing])

select*
FROM RownumCTE
where row_num>1;

--Delete 
--FROM RownumCTE
--where row_num>1;

