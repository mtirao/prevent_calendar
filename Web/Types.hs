module Web.Types where

import IHP.Prelude
import IHP.ModelSupport
import Generated.Types

data WebApplication = WebApplication deriving (Eq, Show)


data StaticController = WelcomeAction deriving (Eq, Show, Data)

data HospitalsController
    = HospitalsAction
    | NewHospitalAction
    | ShowHospitalAction { hospitalId :: !(Id Hospital) }
    | CreateHospitalAction
    | EditHospitalAction { hospitalId :: !(Id Hospital) }
    | UpdateHospitalAction { hospitalId :: !(Id Hospital) }
    | DeleteHospitalAction { hospitalId :: !(Id Hospital) }
    deriving (Eq, Show, Data)

data DoctorsController
    = DoctorsAction
    | NewDoctorAction
    | ShowDoctorAction { doctorId :: !(Id Doctor) }
    | CreateDoctorAction
    | EditDoctorAction { doctorId :: !(Id Doctor) }
    | UpdateDoctorAction { doctorId :: !(Id Doctor) }
    | DeleteDoctorAction { doctorId :: !(Id Doctor) }
    deriving (Eq, Show, Data)

data CalendarsController
    = CalendarsAction
    | NewCalendarAction
    | ShowCalendarAction { calendarId :: !(Id Calendar) }
    | CreateCalendarAction
    | EditCalendarAction { calendarId :: !(Id Calendar) }
    | UpdateCalendarAction { calendarId :: !(Id Calendar) }
    | DeleteCalendarAction { calendarId :: !(Id Calendar) }
    deriving (Eq, Show, Data)
