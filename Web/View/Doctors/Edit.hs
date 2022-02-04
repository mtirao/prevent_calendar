module Web.View.Doctors.Edit where
import Web.View.Prelude

data EditView = EditView { doctor :: Doctor }

instance View EditView where
    html EditView { .. } = [hsx|
        {breadcrumb}
        <h1>Edit Doctor</h1>
        {renderForm doctor}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Doctors" DoctorsAction
                , breadcrumbText "Edit Doctor"
                ]

renderForm :: Doctor -> Html
renderForm doctor = formFor doctor [hsx|
    {(textField #doctorId)}
    {(textField #hospitalId)}
    {(textField #availableDay)}
    {(textField #startShift)}
    {(textField #endShift)}
    {submitButton}

|]