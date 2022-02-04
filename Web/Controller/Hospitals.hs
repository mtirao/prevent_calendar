module Web.Controller.Hospitals where

import Web.Controller.Prelude
import Web.View.Hospitals.Index
import Web.View.Hospitals.New
import Web.View.Hospitals.Edit
import Web.View.Hospitals.Show

instance Controller HospitalsController where
    action HospitalsAction = do
        hospitals <- query @Hospital |> fetch
        render IndexView { .. }

    action NewHospitalAction = do
        let hospital = newRecord
        render NewView { .. }

    action ShowHospitalAction { hospitalId } = do
        hospital <- fetch hospitalId
        render ShowView { .. }

    action EditHospitalAction { hospitalId } = do
        hospital <- fetch hospitalId
        render EditView { .. }

    action UpdateHospitalAction { hospitalId } = do
        hospital <- fetch hospitalId
        hospital
            |> buildHospital
            |> ifValid \case
                Left hospital -> render EditView { .. }
                Right hospital -> do
                    hospital <- hospital |> updateRecord
                    setSuccessMessage "Hospital updated"
                    redirectTo EditHospitalAction { .. }

    action CreateHospitalAction = do
        let hospital = newRecord @Hospital
        hospital
            |> buildHospital
            |> ifValid \case
                Left hospital -> render NewView { .. } 
                Right hospital -> do
                    hospital <- hospital |> createRecord
                    setSuccessMessage "Hospital created"
                    redirectTo HospitalsAction

    action DeleteHospitalAction { hospitalId } = do
        hospital <- fetch hospitalId
        deleteRecord hospital
        setSuccessMessage "Hospital deleted"
        redirectTo HospitalsAction

buildHospital hospital = hospital
    |> fill @["name","address","city","state"]
