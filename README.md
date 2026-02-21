**Project Overview**

This project analyzes Brazil’s e-commerce performance from 2016 to 2018 using SQL (BigQuery) and Tableau.

The objective was to:

•	Evaluate revenue growth trends

•	Identify geographic revenue concentration

•	Analyze delivery performance disparities

•	Assess installment behavior impact on revenue

•	Understand payment method dependency

The final output is a two-page executive Tableau dashboard covering both financial and customer performance insights.

 
**🗂 Dataset**

The dataset includes:

•	Orders

•	Payments

•	Order items

•	Customers

•	Sellers

•	Reviews

•	Geolocation data

Time period: **2016–2018**
 
**🛠 Tools & Technologies**
•	SQL (BigQuery) – Data cleaning, joins, aggregations, KPI calculations
•	Tableau – Dashboard design & visualization
•	GitHub – Documentation & version control
 
**📊 Dashboard Structure**

🧾 **Page 1 – Finance Overview**

Highlights:

•	Yearly revenue trend with YoY growth

•	Revenue distribution by state (map view)

•	Revenue concentration by state share


👥 **Page 2 – Customer & Operational Insights**

1️⃣ Delivery Comparison by State

•	Bottom 5 states exceed the national average delivery time (~18.7 days).

•	Clear regional imbalance in logistics efficiency.

•	Southeast performs closer to or below national average.

2️⃣ Installment Impact

•	Nearly half of all orders use 1 installment (~49K orders).

•	Average payment value increases from ~₹94 to ₹600+ at higher plans.

•	Longer installment plans increase ticket size but reduce adoption.

3️⃣ Payment Method Distribution

•	Credit cards account for ~77% of all transactions.

•	UPI contributes ~19%, while other methods remain minimal.

•	Heavy dependency on credit cards introduces operational and cost risk.


**Technical Approach**

**SQL (BigQuery)**

•	Multi-table joins across orders, payments, and customers

•	Aggregations for:

o	Total Revenue

o	Average Delivery Time

o	Installment-based ticket size

o	Revenue share by state

•	Year-over-Year growth calculations

•	Distinct order count derivation

**Tableau**
•	Multi-page dashboard architecture

•	Scoped filters across worksheets

•	Dual-axis charts (Installment Impact)

•	Reference lines (National Delivery Average)

•	Custom insight panels for executive storytelling

•	Container-based layout design for structured alignment





