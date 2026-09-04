select
    gender,
    customer_type,
    age,
    type_of_travel,
    travel_class,
    flight_distance,

    inflight_wifi_service,
    departure_arrival_time_convenient,
    ease_of_online_booking,
    gate_location,
    food_and_drink,
    online_boarding,
    seat_comfort,
    inflight_entertainment,
    on_board_service,
    leg_room_service,
    baggage_handling,
    checkin_service,
    cleanliness,

    departure_delay_in_minutes,
    arrival_delay_in_minutes,
    satisfaction

from {{ source('raw', 'airline_satisfaction') }}
