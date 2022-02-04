module Web.View.Hospitals.New where
import Web.View.Prelude

data NewView = NewView { hospital :: Hospital }

instance View NewView where
    html NewView { .. } = [hsx|
        {breadcrumb}
        <h1>New Hospital</h1>
        {renderForm hospital}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Hospitals" HospitalsAction
                , breadcrumbText "New Hospital"
                ]

renderForm :: Hospital -> Html
renderForm hospital = formFor hospital [hsx|
    {(textField #name)}
    {(textField #address)}
    {(textField #city)}
    {(textField #state)}
    {submitButton}

|]