# Day 8 Reflection

The most difficult concept in this assignment was preventing double-booking when many buyers try to reserve the same seat simultaneously. Two users may see a seat as available, so the system cannot rely on the seat map or client-side checks alone. I addressed this by using database transactions, row locking, unique constraints on seat claims, and idempotency keys to protect reservations and payment processing.

The feedback on my earlier submission taught me that a design must be complete and properly submitted. Although the requirements, traffic estimates, and API endpoints were useful, the document was missing important sections covering the data model, double-booking prevention, architecture, and trade-offs. I would improve my process by checking every section against the assignment requirements, reviewing the entire document after saving, and confirming that the correct files are committed and pushed to GitHub.

Next, I want to practise load testing and observability. I plan to measure response times, error rates, and database contention under heavy traffic. This will help me understand how transactional seat holds and idempotent payment handling behave when requests arrive simultaneously or payment responses are delayed.
