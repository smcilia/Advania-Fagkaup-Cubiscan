page 50020 "ADV Cubiscan Ingestion Setup"
{
    ApplicationArea = All;
    Caption = 'Cubiscan Data Upload';
    PageType = Card;
    SourceTable = "ADV Cubiscan Ingestion Setup";
    UsageCategory = Administration;
    DeleteAllowed = false; // Only one setup record allowed

    layout
    {
        area(Content)
        {
            Group(Upload)
            {
                Caption = 'Import Cubiscan Data File';
                field(UploadedJsonFile; UploadJsonTxt)
                {
                    ApplicationArea = All;
                    Caption = 'JSON file from Cubiscan';
                    Editable = false;
                    AssistEdit = true;
                    ToolTip = 'Click (…) to select a JSON file to upload.';
                    trigger OnAssistEdit()
                    var
                        FileName: Text;
                        InS: InStream;
                    begin
                        if UploadIntoStream('Select Json file', '', 'JSON files|*.json', FileName, InS) then begin
                            Rec."Uploaded JSON File".ImportStream(InS, FileName);
                            Rec."File Name" := FileName;
                            Rec."Folder Location" := 'Media Upload';
                            Rec.Validate("Uploaded JSON File");
                            Rec.Modify(true);
                            UploadJsonTxt := Rec."File Name";
                        end;
                    end;
                }
                field(FileName; Rec."File Name")
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                    ToolTip = 'File name of uploaded file.';
                    Visible = false;
                }
                field(FolderLocation; Rec."Folder Location")
                {
                    ApplicationArea = All;
                    Caption = 'Folder Location';
                    ToolTip = 'Folder path where the JSON file is stored named Media Upload if uploaded via the client.';
                    Visible = false;
                }
                field(LastUpdate; Rec.LastUpdate)
                {
                    ApplicationArea = All;
                    Caption = 'Last Updated';
                    ToolTip = 'Date and time when the setup was last updated.';
                    Visible = false;
                }
            }
            part(LogEntries; "ADV Cubiscan Ingest. Log List")
            {
                Caption = 'Log Entries';
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ImportJsonFile)
            {
                Caption = 'Import Json File from Cubiscan';
                Image = Import;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    FileName: Text;
                    InS: InStream;
                begin
                    if UploadIntoStream('Select Json file', '', 'JSON files|*.json', FileName, InS) then begin
                        Rec."Uploaded JSON File".ImportStream(InS, FileName);  // MediaSet supports ImportStream                                                    
                        Rec."File Name" := FileName;
                        Rec."Folder Location" := 'Media Upload';
                        Rec.Validate("Uploaded JSON File");
                        Rec.Modify(true);
                        UploadJsonTxt := Rec."File Name";
                        Rec.Validate("Uploaded JSON File");
                        Rec.Modify(true);
                    end;
                end;
            }
            action(ValidateFile)
            {
                Caption = 'Validate Cubiscan JSON';
                Image = TestFile;
                Description = 'Validate the Cubiscan JSON file format.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    CubiscanCodeunit: Codeunit "ADV Cubiscan Ingestion Unit";
                begin
                    CubiscanCodeunit.ValidateFileContents();
                end;
            }
            action(ImportCubiscan)
            {
                Caption = 'Update items with Cubiscan data';
                Image = Import;
                Description = 'Import and update items with the Cubiscan data.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    CubiscanCodeunit: Codeunit "ADV Cubiscan Ingestion Unit";
                begin
                    CubiscanCodeunit.Run();
                    CurrPage.LogEntries.PAGE.Update(false);
                end;
            }
            action(BatchImportCubiscan)
            {
                Caption = 'Batch update items with Cubiscan Data';
                Image = PostBatch;
                Description = 'Run the Cubiscan  in the background.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    CubiscanCodeunitId: Integer;
                begin
                    CubiscanCodeunitId := Codeunit::"ADV Cubiscan Ingestion Unit";
                    CODEUNIT.RUN(CubiscanCodeunitId);
                end;
            }
        }
    }

    trigger OnInit()
    var
        IngestionRec: Record "ADV Cubiscan Ingestion Setup";
    begin
        if not Rec.FindFirst() then begin
            IngestionRec.Init();
            IngestionRec.Key := 'SETUP';
            IngestionRec."Folder Location" := 'Media Upload';
            IngestionRec."File Name" := 'example.json';
            IngestionRec.LastUpdate := CurrentDateTime;
            IngestionRec.Insert();
        end;
    end;

    trigger OnOpenPage()
    begin
        UploadJsonTxt := UploadJsonLabel;
    end;

    var
        UploadJsonTxt: Text;
        UploadJsonLabel: Label 'Click (…) to upload JSON file';


}
