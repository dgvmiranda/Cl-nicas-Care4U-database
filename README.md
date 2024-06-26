# Care4U Clinics Information System-database

## Project Overview
This project involves the creation of a database to support the management of healthcare services at Care4U Clinics. The primary focus is to digitize the internal hospital care system, including inpatient stays and diagnostic exams, involving doctors, technicians, patients, and visitors.

# Universe of Discourse
## Clinics, Rooms, and Schedules
Each clinic has a unique name, inauguration date, corporate identification number (NIPC), address, phone number, email, and operating hours (both non-urgent and visiting hours). Each clinic has a clinical director who is one of the doctors, and this doctor cannot direct more than one clinic simultaneously or be responsible for inpatients during that time.

The clinics have rooms for inpatients and diagnostic exams. Rooms are identified by floor and number. They vary in size and equipment, affecting the types of exams that can be conducted there. Inpatient rooms can be wards or private rooms, each with a maximum capacity for beds and visitors.

## Doctors, Technicians, and Specialties
Information about doctors and technicians includes their tax (NIF) and civil (NIC) identification numbers, name, birth date, start date at each Care4U clinic, gender, address, phone number, and email. Doctors have specialties with an associated daily inpatient rate and may have supervisors within their specialties. Technicians are qualified to perform certain types of exams and have details about the specialties that can issue reports on these exams.

## Exams and Reports
Exams are identified by a code and include details like start and end times, type, room, technician, and prescribing doctor. Each exam results in one or more reports, which can reference other reports for a comprehensive health assessment of the patient.

## Patients, Inpatients, and Visitors
For patients and visitors, the database stores similar information: tax (NIF) and civil (NIC) identification numbers, name, birth date, gender, address, phone number, and email. Visitors may be volunteers and can be contacted to visit patients with fewer personal visits. Internment details include the patient's bed, start date/time, specialty, responsible doctor, and maximum allowed visitors.

## Objectives

**Conceptual Diagram:** Design a minimalistic conceptual diagram modeling the universe of discourse, specifying additional integrity constraints in text form.
**Relational Schema:** Construct the corresponding relational schema using SQL DDL commands, covering as many integrity constraints as possible. Provide SQL DML commands to insert sample data into each table.
