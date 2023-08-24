-- List the bookings made by guest Celine Tam since March 2020. Include also her cancelled bookings. Sort the report by booking date in descending order. 

COLUMN "booking_date" FORMAT A14
SELECT re.reservation_ID, booking_date, booking.*
FROM booking, members, reservation, reservation_detail re
WHERE firstname = 'Celine'
AND lastname = 'Tam'
AND booking.booking_ID = re.booking_ID
AND re.reservation_ID = reservation.reservation_ID
AND reservation.member_ID = members.member_ID
AND TO_CHAR(booking_date, 'MM') BETWEEN 3 AND TO_CHAR(sysdate, 'MM')
ORDER BY booking_date DESC;

-- Produce a report to show the room which has highest maintenance cost for each branch. Write this query with no table joins (i.e., use subqueries).

COLUMN "room_num" FORMAT A10
SELECT hotel_ID, room_num FROM room
WHERE room_num IN (SELECT room_num FROM inspection
WHERE inspect_ID IN (SELECT inspect_ID FROM maintenance
WHERE main_cost IN (SELECT MAX(main_cost) FROM maintenance
WHERE inspect_ID IN (SELECT inspect_ID FROM inspection
WHERE room_num IN (SELECT room_num FROM room
WHERE hotel_ID IN (SELECT hotel_ID FROM branches
WHERE location = 'Ipoh'))))))
UNION
SELECT hotel_ID, room_num FROM room
WHERE room_num IN (SELECT room_num FROM inspection
WHERE inspect_ID IN (SELECT inspect_ID FROM maintenance
WHERE main_cost IN (SELECT MAX(main_cost) FROM maintenance
WHERE inspect_ID IN (SELECT inspect_ID FROM inspection
WHERE room_num IN (SELECT room_num FROM room
WHERE hotel_ID IN (SELECT hotel_ID FROM branches
WHERE location = 'Redang'))))))
UNION
SELECT hotel_ID, room_num FROM room
WHERE room_num IN (SELECT room_num FROM inspection
WHERE inspect_ID IN (SELECT inspect_ID FROM maintenance
WHERE main_cost IN (SELECT MAX(main_cost) FROM maintenance
WHERE inspect_ID IN (SELECT inspect_ID FROM inspection
WHERE room_num IN (SELECT room_num FROM room
WHERE hotel_ID IN (SELECT hotel_ID FROM branches
WHERE location = 'Royal Belum'))))))
UNION
SELECT hotel_ID, room_num FROM room
WHERE room_num IN (SELECT room_num FROM inspection
WHERE inspect_ID IN (SELECT inspect_ID FROM maintenance
WHERE main_cost IN (SELECT MAX(main_cost) FROM maintenance
WHERE inspect_ID IN (SELECT inspect_ID FROM inspection
WHERE room_num IN (SELECT room_num FROM room
WHERE hotel_ID IN (SELECT hotel_ID FROM branches
WHERE location = 'Langkawi'))))))
UNION
SELECT hotel_ID, room_num FROM room
WHERE room_num IN (SELECT room_num FROM inspection
WHERE inspect_ID IN (SELECT inspect_ID FROM maintenance
WHERE main_cost IN (SELECT MAX(main_cost) FROM maintenance
WHERE inspect_ID IN (SELECT inspect_ID FROM inspection
WHERE room_num IN (SELECT room_num FROM room
WHERE hotel_ID IN (SELECT hotel_ID FROM branches
WHERE location = 'Endau Rompin'))))));

-- After a few months of operation, Chillax Resort would like a report on their revenue earned from room rates and request charges, and their expenses spent on the maintenance cost for each branch.

COLUMN "hotel_id" FORMAT A10
SELECT revenue.hotel_ID, total_revenue, total_expenses
FROM 
    (SELECT hotel_id, SUM(total_revenue) AS total_revenue
    FROM
        (SELECT hotel_id,
        (CASE WHEN spe.Request_ID IS NOT NULL THEN
            (CASE WHEN charge IS NOT NULL THEN (room_payment+charge)
                ELSE room_payment
            END)
        ELSE room_payment
        END) total_revenue
        FROM reservation_detail de
        LEFT JOIN special_request spe ON spe.Request_ID = de.Request_ID, room, 
            (SELECT de.reservation_ID, de.booking_ID, (room_date*(Checkout-checkin)) AS room_payment
            FROM reservation re, reservation_detail de, room, room_type, booking
            WHERE room_type.room_code = room.room_code
            AND room.room_num = de.room_num
            AND re.reservation_ID = de.reservation_ID
            AND booking.booking_ID = de.booking_ID
            AND Cancellation_date IS NULL) payment
        WHERE de.reservation_ID = payment.reservation_ID
        AND de.booking_ID = payment.booking_ID
        AND room.room_num = de.room_num)
    GROUP BY hotel_ID) revenue,
    (SELECT hotel_ID, SUM(main_cost) AS total_expenses
    FROM room, inspection, maintenance
    WHERE room.room_num = inspection.room_num
    AND inspection.inspect_ID = maintenance.inspect_ID
    GROUP BY hotel_ID) expenses
WHERE revenue.hotel_ID = expenses.hotel_ID
ORDER BY hotel_ID;