module Web.View.Calendars.Edit where
import Web.View.Prelude

data EditView = EditView { calendar :: Calendar }

instance View EditView where
    html EditView { .. } = [hsx|
        {breadcrumb}
        <h1>Edit Calendar</h1>
        {renderForm calendar}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Calendars" CalendarsAction
                , breadcrumbText "Edit Calendar"
                ]

renderForm :: Calendar -> Html
renderForm calendar = formFor calendar [hsx|
    {(textField #doctorId)}
    {submitButton}

|]