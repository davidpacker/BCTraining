namespace aldev.vendorQuality.VendoerQuality;

using Microsoft.Purchases.Vendor;

tableextension 50800 "Vendor Ext" extends Vendor
{
    fields
    {
        field(50800; "Vendor Score"; Decimal)
        {
            Caption = 'Vendor Score';
            Editable = false;
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 10;

            FieldClass = FlowField;
            CalcFormula = lookup("Vendor Quality Assessment"."Overall Rating" where("Vendor No." = field("No.")));
        }
        modify(Name)
        {
            trigger OnAfterValidate()
            begin
                Message('Vendor Name is %1', Name);
            end;

        }
    }

}