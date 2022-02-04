module Web.View.Calendars.New where
import Web.View.Prelude

data NewView = NewView { calendar :: Calendar }

instance View NewView where
    html NewView { .. } = [hsx|
        {breadcrumb}
        <h1>New Calendar</h1>
        {renderForm calendar}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Calendars" CalendarsAction
                , breadcrumbText "New Calendar"
                ]

renderForm :: Calendar -> Html
renderForm calendar = formFor calendar [hsx|
    {(textField #doctorId)}
    {submitButton}

|]