CREATE TABLE calendars (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    doctor_id UUID NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);
CREATE INDEX calendars_doctor_id_index ON calendars (doctor_id);
ALTER TABLE calendars ADD CONSTRAINT calendars_ref_doctor_id FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE NO ACTION;
