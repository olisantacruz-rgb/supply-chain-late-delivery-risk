-- Build order-level numerical features from the raw order-item table.
-- The raw_orders table is registered from Python.

WITH item_aggregation AS (
    SELECT
        "Order Id" AS order_id,
        COUNT(*) AS order_line_count,
        SUM("Order Item Quantity") AS total_item_quantity,
        COUNT(DISTINCT "Product Card Id") AS distinct_products,
        COUNT(DISTINCT "Category Id") AS distinct_categories,
        COUNT(DISTINCT "Department Id") AS distinct_departments,
        SUM("Sales") AS gross_sales,
        SUM("Order Item Discount") AS total_discount,
        SUM("Order Item Total") AS net_sales,
        SUM("Order Profit Per Order") AS total_profit
    FROM raw_orders
    GROUP BY "Order Id"
),

derived_metrics AS (
    SELECT
        *,
        gross_sales
            / NULLIF(total_item_quantity, 0)
            AS weighted_avg_unit_price,

        total_discount
            / NULLIF(gross_sales, 0)
            AS order_discount_rate,

        total_profit
            / NULLIF(net_sales, 0)
            AS order_profit_margin

    FROM item_aggregation
)

SELECT *
FROM derived_metrics
ORDER BY order_id;
