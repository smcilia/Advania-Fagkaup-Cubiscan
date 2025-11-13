/// <summary>
/// Used to display log list on default page
/// </summary>
page 50021 "ADV Cubiscan Ingest. Log List"
{
    PageType = ListPart;
    SourceTable = "ADV Cubiscan Ingestion Log";
    ApplicationArea = All;
    Caption = 'Cubiscan Processing Log Entries';
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("TimeIngested"; "TimeIngested")
                {
                    ApplicationArea = All;
                }
                field("JSON File Name"; "JSON File Name")
                {
                    ApplicationArea = All;
                }
                field("Barcode"; "Barcode")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Net Length"; "Net Length")
                {
                    ApplicationArea = All;
                }
                field("Net Width"; "Net Width")
                {
                    ApplicationArea = All;
                }
                field("Net Height"; "Net Height")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; "Net Weight")
                {
                    ApplicationArea = All;
                }
                field("Net Volume"; "Net Volume")
                {
                    ApplicationArea = All;
                }
                field("Net Dim Wgt"; "Net Dim Wgt")
                {
                    ApplicationArea = All;
                }
                field("Description"; "Description")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Status"; "Status")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
