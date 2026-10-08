# School Database Design

## Students Table

The `students` table stores information about students. It contains the student's unique ID, name, and email address. The `id` column is the primary key, while the email address is required and must be unique so that two students cannot register with the same email.

## Courses Table

The `courses` table stores the courses offered by the school. Each course has a unique ID and a required course name. The `id` column is the primary key.

## Enrolments Table

The `enrolments` table records which students are enrolled in which courses. It also stores the student's grade for that course. It contains foreign keys referencing the `students` and `courses` tables. The combination of `student_id` and `course_id` is unique, which prevents the same student from enrolling in the same course more than once.

## Relationships

There is a one-to-many relationship between students and enrolments because one student can have many enrolments, while each enrolment belongs to one student.

There is also a one-to-many relationship between courses and enrolments because one course can have many enrolments, while each enrolment belongs to one course.

Students and courses have a many-to-many relationship because one student can take many courses and one course can have many students. The `enrolments` table is therefore needed as a join table to connect students and courses. It also provides a place to store information about the relationship, such as the student's grade.

## Index

I would add an index on `enrolments.student_id` because student-based queries are common, such as finding all courses taken by a particular student. An index can make these searches faster, especially when the database contains many enrolments.

## SQL or NoSQL?

I would choose SQL for this school system because the data has clear relationships between students, courses, and enrolments. SQL databases are well suited to structured data and relational queries involving JOIN, GROUP BY, foreign keys, and constraints. SQL also provides strong data integrity through primary keys, foreign keys, unique constraints, and NOT NULL rules. A NoSQL database could work for a larger or less structured system, but SQL is a better fit for this particular school database.
