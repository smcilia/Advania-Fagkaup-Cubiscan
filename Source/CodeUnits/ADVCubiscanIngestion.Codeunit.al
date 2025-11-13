/// <summary>
/// Error checking of Json file and  updating of data
/// </summary>
codeunit 50034 "ADV Cubiscan Ingestion Unit"
{
    trigger OnRun()
    begin
        ImportCubiscanJson();
    end;

    procedure RetrieveJSONToken(): JsonToken
    var
        Setup: Record "ADV Cubiscan Ingestion Setup";
        FileContent: Text;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        OutStream: OutStream;
        InStream: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        if not Setup.Get('SETUP') then begin
            CreateLogEntry('', '', '', '', 0, 0, 0, 0, 0, 0, 'No setup record found.', false);
        end;

        if not Setup."Uploaded JSON File".HasValue then begin
            CreateLogEntry('', '', '', '', 0, 0, 0, 0, 0, 0, 'No uploaded JSON file found in Setup record.', false);
        end;

        TempBlob.CreateOutStream(OutStream);
        Setup."Uploaded JSON File".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream);
        InStream.Read(FileContent);
        FileName := Setup."File Name";

        if not JsonObject.ReadFrom(FileContent) then begin
            CreateLogEntry('', FileName, '', '', 0, 0, 0, 0, 0, 0, 'Invalid JSON format.', false);
            exit
        end;

        if not JsonObject.Get('DATA', JsonToken) then begin
            CreateLogEntry('', FileName, '', '', 0, 0, 0, 0, 0, 0, 'DATA array not found in JSON.', false);
            exit
        end;

        exit(JsonToken);
    end;

    procedure ValidateFileContents()
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        Setup: Record "ADV Cubiscan Ingestion Setup";
        FileContent: Text;
        OutStream: OutStream;
        InStream: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        if not Setup.Get('SETUP') then begin
            Error('Setup record not found.');
        end;

        if not Setup."Uploaded JSON File".HasValue then begin
            Error('No uploaded JSON file found in Setup record.');
        end;

        TempBlob.CreateOutStream(OutStream);
        Setup."Uploaded JSON File".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream);
        InStream.Read(FileContent);
        FileName := Setup."File Name";

        if not JsonObject.ReadFrom(FileContent) then begin
            Error('Invalid JSON format.');
        end;

        if not JsonObject.Get('DATA', JsonToken) then begin
            Error('DATA array not found in JSON.');
        end;

        Message('JSON file is valid with %1 entries.', JsonToken.AsArray().Count());
    end;

    local procedure ImportCubiscanJson()
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        ItemRef: Record "Item Reference";
        JsonToken: JsonToken;
        ItemBarcode: Code[50];
        j: JsonToken;
        EntryObj: JsonObject;
        NetLength, NetWidth, NetHeight, NetWeight, NetVolume, NetDimWgt : Decimal;
        Barcode: Text;
        NetLengthToken, NetWidthToken, NetHeightToken, NetWeightToken, NetVolumeToken, NetDimWgtToken, BarcodeToken : JsonToken;
        ItemRefUOM: Code[10];
        ItemRefItemNo: Code[20];
        ValdidateWeight: Boolean;
    begin
        JsonToken := RetrieveJSONToken();

        foreach j in JsonToken.AsArray() do begin
            begin
                EntryObj := j.AsObject();
                EntryObj.Get('NET_LENGTH', NetLengthToken);
                EntryObj.Get('NET_WIDTH', NetWidthToken);
                EntryObj.Get('NET_HEIGHT', NetHeightToken);
                EntryObj.Get('NET_WEIGHT', NetWeightToken);
                EntryObj.Get('NET_VOLUME', NetVolumeToken);
                EntryObj.Get('NET_DIM_WGT', NetDimWgtToken);
                EntryObj.Get('ITEM_ID', BarcodeToken);

                NetLength := NetLengthToken.AsValue().AsDecimal();
                NetWidth := NetWidthToken.AsValue().AsDecimal();
                NetHeight := NetHeightToken.AsValue().AsDecimal();
                NetWeight := NetWeightToken.AsValue().AsDecimal();
                NetVolume := NetVolumeToken.AsValue().AsDecimal();
                NetDimWgt := NetDimWgtToken.AsValue().AsDecimal();
                Barcode := BarcodeToken.AsValue().AsText();

                ItemRef.SetRange("Reference No.", Barcode);
                ItemRef.SetFilter("Reference Type", 'Bar Code');
                ValdidateWeight := false;
                if ItemRef.FindFirst() then begin
                    ItemRefUOM := ItemRef."Unit of Measure";
                    ItemRefItemNo := ItemRef."Item No.";
                    if Item.Get(ItemRef."Item No.") then begin
                        if item."Sales Unit of Measure" = ItemRefUOM then begin
                            Item."Net Weight" := NetWeight;
                            Item."Unit Volume" := NetVolume;
                            Item.Modify(true);
                            ValdidateWeight := true;
                            CreateLogEntry(Barcode, FileName, ItemRefItemNo, ItemRefUOM, NetLength, NetWidth, NetHeight, NetWeight, NetVolume, NetDimWgt, 'Item updated successfully', true);
                        end;
                        if ItemUOM.Get(ItemRefItemNo, ItemRefUOM) then begin
                            ItemUOM.Height := NetHeight;
                            ItemUOM.Length := NetLength;
                            ItemUOM.Width := NetWidth;
                            ItemUOM.Validate("Height"); //Done to calculate cubage (volume)
                            if ValdidateWeight then //If Item was updated, then validate weight also via Validate on Item No.
                                ItemUOM.Validate("Item No.");
                            ItemUOM.Modify(true);
                            CreateLogEntry(Barcode, FileName, ItemRefItemNo, ItemRefUOM, NetLength, NetWidth, NetHeight, NetWeight, NetVolume, NetDimWgt, 'Item Unit of Measure updated successfully', true);
                        end;
                    end;
                end
                else begin
                    CreateLogEntry(Barcode, FileName, '', '', NetLength, NetWidth, NetHeight, NetWeight, NetVolume, NetDimWgt, 'Item not found for barcode', false);
                end;
            end;
        end;
    end;

    procedure CreateLogEntry(Barcode: Text; JsonFileName: Text; ItemNo: Code[20]; UOM: Code[10]; NetLength: Decimal; NetWidth: Decimal; NetHeight: Decimal; NetWeight: Decimal; NetVolume: Decimal; NetDimWgt: Decimal; Description: Text; Success: Boolean)
    var
        IngestionLog: Record "ADV Cubiscan Ingestion Log";
    begin
        IngestionLog.Reset();
        IngestionLog.Init();
        IngestionLog."TimeIngested" := CurrentDateTime;
        IngestionLog."JSON File Name" := JsonFileName;
        IngestionLog."Barcode" := Barcode;
        IngestionLog."Item No." := ItemNo;
        IngestionLog."Unit of Measure" := UOM;
        IngestionLog."Net Length" := NetLength;
        IngestionLog."Net Width" := NetWidth;
        IngestionLog."Net Height" := NetHeight;
        IngestionLog."Net Weight" := NetWeight;
        IngestionLog."Net Volume" := NetVolume;
        IngestionLog."Net Dim Wgt" := NetDimWgt;
        IngestionLog."Description" := Description;
        IngestionLog."User ID" := UserId;
        if Success then
            IngestionLog.Status := IngestionLog.Status::Success
        else
            IngestionLog.Status := IngestionLog.Status::Failure;
        IngestionLog.Insert();
        Commit();
    end;

    var
        FileName: Text;
}
