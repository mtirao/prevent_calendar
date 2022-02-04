module Web.View.Hospitals.Show where
import Web.View.Prelude

data ShowView = ShowView { hospital :: Hospital }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Hospital</h1>
        <p>{hospital}</p>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Hospitals" HospitalsAction
                            , breadcrumbText "Show Hospital"
                            ]