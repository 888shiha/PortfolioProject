#DATA CLEANING
#Converting the Format of PurchaseDate column and changing it from Text to DATETIME
UPDATE orders
SET PurchaseDate = STR_TO_DATE(PurchaseDate, '%c/%e/%Y %H:%i');

ALTER TABLE orders
MODIFY COLUMN PurchaseDate DATETIME;

#Converting the Format of ApprovalDate column and changing it from Text to DATETIME
UPDATE orders
SET ApprovalDate = STR_TO_DATE(ApprovalDate, '%c/%e/%Y %H:%i');

ALTER TABLE orders
MODIFY COLUMN ApprovalDate DATETIME;

#Converting the Format of CarrierDeliveryDate column and changing it from Text to DATETIME
UPDATE orders
SET CarrierDeliveryDate = STR_TO_DATE(CarrierDeliveryDate, '%c/%e/%Y %H:%i');

ALTER TABLE orders
MODIFY COLUMN CarrierDeliveryDate DATETIME;

#Converting the Format of CustomerDeliveryDate column and changing it from Text to DATETIME
UPDATE orders
SET CustomerDeliveryDate = STR_TO_DATE(CustomerDeliveryDate, '%c/%e/%Y %H:%i');

ALTER TABLE orders
MODIFY COLUMN CustomerDeliveryDate DATETIME;

#Converting the Format of EstimatedDeliveryDate column and changing it from Text to DATETIME
UPDATE orders
SET EstimatedDeliveryDate = STR_TO_DATE(EstimatedDeliveryDate, '%c/%e/%Y %H:%i');

ALTER TABLE orders
MODIFY COLUMN EstimatedDeliveryDate DATETIME;

#Converting the Format of ReviewDate column and changing it from Text to DATETIME
UPDATE ratings
SET ReviewDate = STR_TO_DATE(ReviewDate, '%c/%e/%Y %H:%i');

ALTER TABLE ratings
MODIFY COLUMN ReviewDate DATETIME;

#Converting the Format of ReviewResponseDate column and changing it from Text to DATETIME
UPDATE ratings
SET ReviewResponseDate = STR_TO_DATE(ReviewResponseDate, '%c/%e/%Y %H:%i');

ALTER TABLE ratings
MODIFY COLUMN ReviewResponseDate DATETIME;

#Converting the Format of ShippingLimitDate column and changing it from Text to DATETIME
UPDATE orderdetails
SET ShippingLimitDate = STR_TO_DATE(ShippingLimitDate, '%c/%e/%Y %H:%i');

ALTER TABLE orderdetails
MODIFY COLUMN ShippingLimitDate DATETIME;

#DATA ANALYSIS

#Question 2: Does an extensive product name, description, or image set impact how well a product sells?
SELECT COUNT(od.ProductID) AS NumSold, NameLength
FROM orderdetails od
JOIN products p ON od.ProductID = p.ProductID
GROUP BY NameLength
ORDER BY NumSold DESC
;
SELECT COUNT(od.ProductID) AS NumSold, DescriptionLength
FROM orderdetails od
JOIN products p ON od.ProductID = p.ProductID
GROUP BY DescriptionLength
ORDER BY NumSold DESC
;
SELECT COUNT(od.ProductID) AS NumSold, NumberOfPhotos
FROM orderdetails od
JOIN products p ON od.ProductID = p.ProductID
GROUP BY NumberOfPhotos
ORDER BY NumSold DESC
;
#Strong correlation. Visualize in Excel.

#Question 4: How many times a seller waited 20 or more days to respond to 1 or 2 or 3 star customer reviews 3 or more times
SELECT s.SellerID, COUNT(TIMESTAMPDIFF(DAY, ReviewDate, ReviewResponseDate)) AS NumOfTimes
FROM ratings r
JOIN orders o ON r.OrderID = o.OrderID
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN sellers s ON od.SellerID = s.SellerID
WHERE TIMESTAMPDIFF(DAY, ReviewDate, ReviewResponseDate) >= 20 AND Score IN (1,2,3)
GROUP BY s.SellerID
HAVING NumOfTimes >= 3
ORDER BY NumOfTimes DESC
;

#Question 5:
SELECT SellerID, COUNT(TIMESTAMPDIFF(DAY, PurchaseDate, CustomerDeliveryDate)) AS NumOfTimes
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
WHERE TIMESTAMPDIFF(DAY, PurchaseDate, CustomerDeliveryDate) > 30
GROUP BY SellerID
HAVING NumOfTimes >= 15
ORDER BY NumOfTimes DESC
;

SELECT s.SellerID, count(*)
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN sellers s ON od.SellerID = s.SellerID
WHERE TIMESTAMPDIFF(DAY, PurchaseDate, CustomerDeliveryDate) > 30
GROUP BY s.SellerID
HAVING count(*) >= 5
ORDER BY count(*) DESC






























































