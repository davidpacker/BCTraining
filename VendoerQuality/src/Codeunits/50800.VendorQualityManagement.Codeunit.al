namespace aldev.vendorQuality.VendoerQuality;

codeunit 50800 "Vendor Quality Management"
{
    procedure IsVendorQualityAcceptable(VendorNo: Code[20]): Boolean
    var
        VendorQualityAssessment: Record "Vendor Quality Assessment";
        VendorQualitySetup: Record "Vendor Quality Setup";
    begin
        if not VendorQualitySetup.Get() then
            exit(true); // If setup not found, assume acceptable

        if not VendorQualityAssessment.Get(VendorNo) then
            exit(true); // No assessment found, assume acceptable

        exit(VendorQualityAssessment."Overall Rating" >= VendorQualitySetup."Minimum Accepted Vendor Rate");
    end;

    procedure GetVendorRatingText(VendorNo: Code[20]): Text
    var
        VendorQualityAssessment: Record "Vendor Quality Assessment";
        VendorQualitySetup: Record "Vendor Quality Setup";
    begin
        if not VendorQualitySetup.Get() then
            exit('');

        if not VendorQualityAssessment.Get(VendorNo) then
            exit('Not Assessed');

        if VendorQualityAssessment."Overall Rating" >= VendorQualitySetup."Minimum Accepted Vendor Rate" then
            exit(StrSubstNo('Acceptable (%1)', Format(VendorQualityAssessment."Overall Rating", 0, '<Precision,2:><Standard Format,1>')))
        else
            exit(StrSubstNo('Unacceptable (%1)', Format(VendorQualityAssessment."Overall Rating", 0, '<Precision,2:><Standard Format,1>')));
    end;
}