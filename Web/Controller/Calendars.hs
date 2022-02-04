module Web.Controller.Calendars where

import Web.Controller.Prelude
import Web.View.Calendars.Index
import Web.View.Calendars.New
import Web.View.Calendars.Edit
import Web.View.Calendars.Show

instance Controller CalendarsController where
    action CalendarsAction = do
        calendars <- query @Calendar |> fetch
        render IndexView { .. }

    action NewCalendarAction = do
        let calendar = newRecord
        render NewView { .. }

    action ShowCalendarAction { calendarId } = do
        calendar <- fetch calendarId
        render ShowView { .. }

    action EditCalendarAction { calendarId } = do
        calendar <- fetch calendarId
        render EditView { .. }

    action UpdateCalendarAction { calendarId } = do
        calendar <- fetch calendarId
        calendar
            |> buildCalendar
            |> ifValid \case
                Left calendar -> render EditView { .. }
                Right calendar -> do
                    calendar <- calendar |> updateRecord
                    setSuccessMessage "Calendar updated"
                    redirectTo EditCalendarAction { .. }

    action CreateCalendarAction = do
        let calendar = newRecord @Calendar
        calendar
            |> buildCalendar
            |> ifValid \case
                Left calendar -> render NewView { .. } 
                Right calendar -> do
                    calendar <- calendar |> createRecord
                    setSuccessMessage "Calendar created"
                    redirectTo CalendarsAction

    action DeleteCalendarAction { calendarId } = do
        calendar <- fetch calendarId
        deleteRecord calendar
        setSuccessMessage "Calendar deleted"
        redirectTo CalendarsAction

buildCalendar calendar = calendar
    |> fill @'["doctorId"]
