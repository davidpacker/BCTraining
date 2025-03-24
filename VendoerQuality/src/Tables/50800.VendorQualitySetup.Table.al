namespace aldev.vendorQuality.VendoerQuality;

table 50800 "Vendor Quality Setup"
{
    Caption = 'Vendor Quality Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(50800; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(50801; "Minimum Accepted Vendor Rate"; Decimal)
        {
            Caption = 'Minimum Accepted Vendor Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
            DecimalPlaces = 2;
        }
        field(50802; "Item Quality Rate"; Decimal)
        {
            Caption = 'Item Quality Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2;
        }
        field(50803; "Delivery On Time Rate"; Decimal)
        {
            Caption = 'Delivery On Time Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2;
        }
        field(50804; "Item Packaging Rate"; Decimal)
        {
            Caption = 'Item Packaging Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2;
        }
        field(50805; "Pricing Rate"; Decimal)
        {
            Caption = 'Pricing Rate';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2;

        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}