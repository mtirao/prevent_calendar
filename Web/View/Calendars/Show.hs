module Web.View.Calendars.Show where
import Web.View.Prelude

data ShowView = ShowView { calendar :: Calendar }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Calendar</h1>
        <p>{calendar}</p>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Calendars" CalendarsAction
                            , breadcrumbText "Show Calendar"
                            ]