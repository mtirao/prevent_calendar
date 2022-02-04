CREATE TABLE hospitals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL
);
CREATE TABLE doctors (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    doctor_id UUID NOT NULL,
    hospital_id UUID NOT NULL,
    available_day INT DEFAULT 0 NOT NULL,
    start_shift REAL NOT NULL,
    end_shift TEXT NOT NULL
);
CREATE INDEX doctors_doctor_id_index ON doctors (doctor_id);
CREATE INDEX doctors_hospital_id_index ON doctors (hospital_id);
ALTER TABLE doctors ADD CONSTRAINT doctors_ref_hospital_id FOREIGN KEY (hospital_id) REFERENCES hospitals (id) ON DELETE NO ACTION;
