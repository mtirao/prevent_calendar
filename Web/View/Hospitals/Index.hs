module Web.View.Hospitals.Index where
import Web.View.Prelude

data IndexView = IndexView { hospitals :: [ Hospital ]  }

instance View IndexView where
    html IndexView { .. } = [hsx|
        {breadcrumb}

        <h1>Index<a href={pathTo NewHospitalAction} class="btn btn-primary ml-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Hospital</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach hospitals renderHospital}</tbody>
            </table>
            
        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Hospitals" HospitalsAction
                ]

renderHospital :: Hospital -> Html
renderHospital hospital = [hsx|
    <tr>
        <td>{hospital}</td>
        <td><a href={ShowHospitalAction (get #id hospital)}>Show</a></td>
        <td><a href={EditHospitalAction (get #id hospital)} class="text-muted">Edit</a></td>
        <td><a href={DeleteHospitalAction (get #id hospital)} class="js-delete text-muted">Delete</a></td>
    </tr>
|]