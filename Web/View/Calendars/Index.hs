module Web.View.Calendars.Index where
import Web.View.Prelude

data IndexView = IndexView { calendars :: [ Calendar ]  }

instance View IndexView where
    html IndexView { .. } = [hsx|
        {breadcrumb}

        <h1>Index<a href={pathTo NewCalendarAction} class="btn btn-primary ml-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Calendar</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach calendars renderCalendar}</tbody>
            </table>
            
        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Calendars" CalendarsAction
                ]

renderCalendar :: Calendar -> Html
renderCalendar calendar = [hsx|
    <tr>
        <td>{calendar}</td>
        <td><a href={ShowCalendarAction (get #id calendar)}>Show</a></td>
        <td><a href={EditCalendarAction (get #id calendar)} class="text-muted">Edit</a></td>
        <td><a href={DeleteCalendarAction (get #id calendar)} class="js-delete text-muted">Delete</a></td>
    </tr>
|]