module Web.View.Doctors.Show where
import Web.View.Prelude

data ShowView = ShowView { doctor :: Doctor }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Doctor</h1>
        <p>{doctor}</p>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Doctors" DoctorsAction
                            , breadcrumbText "Show Doctor"
                            ]