// <copyright file="20250814111830_AddOrgScopedUniqueUserName.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MeetlyOmni.Api.Migrations;

/// <inheritdoc />
public partial class AddOrgScopedUniqueUserName : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateIndex(
            name: "UK_Member_Org_NormalizedUserName",
            table: "AspNetUsers",
            columns: new[] { "OrgId", "NormalizedUserName" },
            unique: true);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "UK_Member_Org_NormalizedUserName",
            table: "AspNetUsers");
    }
}
