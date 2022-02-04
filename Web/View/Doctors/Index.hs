module Web.View.Doctors.Index where
import Web.View.Prelude

data IndexView = IndexView { doctors :: [ Doctor ]  }

instance View IndexView where
    html IndexView { .. } = [hsx|
        {breadcrumb}

        <h1>Index<a href={pathTo NewDoctorAction} class="btn btn-primary ml-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Doctor</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach doctors renderDoctor}</tbody>
            </table>
            
        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Doctors" DoctorsAction
                ]

renderDoctor :: Doctor -> Html
renderDoctor doctor = [hsx|
    <tr>
        <td>{doctor}</td>
        <td><a href={ShowDoctorAction (get #id doctor)}>Show</a></td>
        <td><a href={EditDoctorAction (get #id doctor)} class="text-muted">Edit</a></td>
        <td><a href={DeleteDoctorAction (get #id doctor)} class="js-delete text-muted">Delete</a></td>
    </tr>
|]