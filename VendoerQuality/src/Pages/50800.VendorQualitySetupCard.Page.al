namespace aldev.vendorQuality.VendoerQuality;

page 50800 "Vendor Quality Setup Card"
{
    Caption = 'Vendor Quality Setup';
    PageType = Card;
    SourceTable = "Vendor Quality Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Minimum Accepted Vendor Rate"; Rec."Minimum Accepted Vendor Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum acceptable rating for vendors';
                }
            }

            group(Weights)
            {
                Caption = 'Category Weights';

                field("Item Quality Rate"; Rec."Item Quality Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight percentage for item quality in vendor rating';
                }
                field("Delivery On Time Rate"; Rec."Delivery On Time Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight percentage for delivery time in vendor rating';
                }
                field("Item Packaging Rate"; Rec."Item Packaging Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight percentage for packaging quality in vendor rating';
                }
                field("Pricing Rate"; Rec."Pricing Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight percentage for pricing in vendor rating';
                }
            }
        }
    }

}