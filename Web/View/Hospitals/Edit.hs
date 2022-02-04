module Web.View.Hospitals.Edit where
import Web.View.Prelude

data EditView = EditView { hospital :: Hospital }

instance View EditView where
    html EditView { .. } = [hsx|
        {breadcrumb}
        <h1>Edit Hospital</h1>
        {renderForm hospital}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Hospitals" HospitalsAction
                , breadcrumbText "Edit Hospital"
                ]

renderForm :: Hospital -> Html
renderForm hospital = formFor hospital [hsx|
    {(textField #name)}
    {(textField #address)}
    {(textField #city)}
    {(textField #state)}
    {submitButton}

|]