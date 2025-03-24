namespace aldev.vendorQuality.VendoerQuality;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

table 50801 "Vendor Quality Assessment"
{
    Caption = 'Vendor Quality Assessment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No." where(Blocked = const(" "));
        }
        field(2; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(10; "Item Quality Score"; Decimal)
        {
            Caption = 'Item Quality Score';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
            DecimalPlaces = 2;
        }
        field(20; "Delivery On Time Score"; Decimal)
        {
            Caption = 'Delivery On Time Score';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
            DecimalPlaces = 2;
        }
        field(30; "Item Packaging Score"; Decimal)
        {
            Caption = 'Item Packaging Score';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
            DecimalPlaces = 2;
        }
        field(40; "Pricing Score"; Decimal)
        {
            Caption = 'Pricing Score';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
            DecimalPlaces = 2;
        }
        field(50; "Overall Rating"; Decimal)
        {
            Caption = 'Overall Rating';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
            DecimalPlaces = 2;
            Editable = false;
        }
        field(60; "Last Assessment Date"; Date)
        {
            Caption = 'Last Assessment Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // New financial fields
        field(70; "Current Year Amount"; Decimal)
        {
            Caption = 'Current Year Invoiced Amount';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2;
        }
        field(71; "Previous Year Amount"; Decimal)
        {
            Caption = 'Previous Year Invoiced Amount';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2;
        }
        field(72; "Two Years Ago Amount"; Decimal)
        {
            Caption = 'Two Years Ago Invoiced Amount';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2;
        }
        field(73; "Amount Due"; Decimal)
        {
            Caption = 'Total Amount Due';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2;
        }
        field(74; "Amount To Pay"; Decimal)
        {
            Caption = 'Total Amount To Pay (Not Due)';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2;
        }
        field(75; "Last Financial Update"; DateTime)
        {
            Caption = 'Last Financial Update';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Vendor No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Last Assessment Date" := WorkDate();
        CalculateOverallRating();
        UpdateFinancialData();
    end;

    trigger OnModify()
    begin
        "Last Assessment Date" := WorkDate();
        CalculateOverallRating();
    end;

    procedure CalculateOverallRating()
    var
        VendorQualitySetup: Record "Vendor Quality Setup";
        TotalWeight: Decimal;
    begin
        if not VendorQualitySetup.Get() then begin
            VendorQualitySetup.Init();
            VendorQualitySetup.Insert();
        end;

        TotalWeight := VendorQualitySetup."Item Quality Rate" +
                      VendorQualitySetup."Delivery On Time Rate" +
                      VendorQualitySetup."Item Packaging Rate" +
                      VendorQualitySetup."Pricing Rate";

        if TotalWeight = 0 then
            "Overall Rating" := 0
        else
            "Overall Rating" := ("Item Quality Score" * VendorQualitySetup."Item Quality Rate" +
                               "Delivery On Time Score" * VendorQualitySetup."Delivery On Time Rate" +
                               "Item Packaging Score" * VendorQualitySetup."Item Packaging Rate" +
                               "Pricing Score" * VendorQualitySetup."Pricing Rate") / TotalWeight;
    end;

    procedure UpdateFinancialData()
    var
        StartDate: Date;
        EndDate: Date;
    begin
        // Current Year
        StartDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3));
        EndDate := DMY2Date(31, 12, Date2DMY(WorkDate(), 3));
        "Current Year Amount" := CalculateVendorAmount(StartDate, EndDate);

        // Previous Year
        StartDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3) - 1);
        EndDate := DMY2Date(31, 12, Date2DMY(WorkDate(), 3) - 1);
        "Previous Year Amount" := CalculateVendorAmount(StartDate, EndDate);

        // Two Years Ago
        StartDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3) - 2);
        EndDate := DMY2Date(31, 12, Date2DMY(WorkDate(), 3) - 2);
        "Two Years Ago Amount" := CalculateVendorAmount(StartDate, EndDate);

        // Amount Due
        "Amount Due" := GetAmountDue();

        // Amount To Pay
        "Amount To Pay" := GetAmountToPay();

        // Update timestamp
        "Last Financial Update" := CurrentDateTime;
        if Modify() then;
    end;

    local procedure CalculateVendorAmount(StartDate: Date; EndDate: Date): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TotalAmount: Decimal;
    begin
        VendorLedgerEntry.SetRange("Vendor No.", "Vendor No.");
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.CalcFields("Amount (LCY)");
                TotalAmount += VendorLedgerEntry."Amount (LCY)";
            until VendorLedgerEntry.Next() = 0;
        exit(Abs(TotalAmount));
    end;

    local procedure GetAmountDue(): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TotalAmountDue: Decimal;
    begin
        VendorLedgerEntry.SetRange("Vendor No.", "Vendor No.");
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetFilter("Due Date", '..%1', WorkDate());
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.CalcFields("Remaining Amount");
                TotalAmountDue += VendorLedgerEntry."Remaining Amount";
            until VendorLedgerEntry.Next() = 0;
        exit(Abs(TotalAmountDue));
    end;

    local procedure GetAmountToPay(): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TotalAmountToPay: Decimal;
    begin
        VendorLedgerEntry.SetRange("Vendor No.", "Vendor No.");
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetFilter("Due Date", '>%1', WorkDate());
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.CalcFields("Remaining Amount");
                TotalAmountToPay += VendorLedgerEntry."Remaining Amount";
            until VendorLedgerEntry.Next() = 0;
        exit(Abs(TotalAmountToPay));
    end;
}