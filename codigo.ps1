# Definir dominio
$domain = "DC=frikyland,DC=bcn"  # Reemplaza con el dominio de tu organización

# Lista de OUs principales y secundarias
$ouHierarchy = @(
    @{ Name = "Frikyland"; Parent = $null },
    @{ Name = "Dirección"; Parent = "Frikyland" },
    @{ Name = "Finanzas"; Parent = "Dirección" },
    @{ Name = "Contabilidad"; Parent = "Finanzas" },
    @{ Name = "Compras"; Parent = "Finanzas" },
    @{ Name = "Operaciones"; Parent = "Dirección" },
    @{ Name = "Transportes"; Parent = "Operaciones" },
    @{ Name = "Almacén"; Parent = "Operaciones" },
    @{ Name = "IT"; Parent = "Dirección" },
    @{ Name = "Desarrollos"; Parent = "IT" },
    @{ Name = "Sistemas"; Parent = "IT" }
)

# Crear las OUs
foreach ($ou in $ouHierarchy) {
    # Construir el DistinguishedName según la jerarquía
    if ($ou.Parent -eq $null) {
        $ouPath = $domain
    } else {
        $parentOuDistinguishedName = "OU=$($ou.Parent),$domain"
        $ouPath = $parentOuDistinguishedName
    }

    $ouDistinguishedName = "OU=$($ou.Name),$ouPath"

    # Crear la OU si no existe
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDistinguishedName'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ouPath -ProtectedFromAccidentalDeletion $true
        Write-Host "OU '$($ou.Name)' creada bajo '$ouPath'."
    } else {
        Write-Host "La OU '$($ou.Name)' ya existe en '$ouPath'."
    }
}

# Crear los usuarios
$userList = @(
    @{ Name = "Amador Rivas"; Username = "amador.rivas"; Password = "Password123!"; OU = "Dirección" },
    @{ Name = "Mario Conde"; Username = "mario.conde"; Password = "Password123!"; OU = "Finanzas" },
    @{ Name = "Álvaro Pérez"; Username = "alvaro.perez"; Password = "Password123!"; OU = "Operaciones" },
    @{ Name = "Steve Gates"; Username = "steve.gates"; Password = "Password123!"; OU = "IT" },
    @{ Name = "Cristina Prada"; Username = "cristina.prada"; Password = "Password123!"; OU = "Contabilidad" },
    @{ Name = "Agatha Ruiz"; Username = "agatha.ruiz"; Password = "Password123!"; OU = "Contabilidad" },
    @{ Name = "Leonardo García"; Username = "leonardo.garcia"; Password = "Password123!"; OU = "Compras" },
    @{ Name = "Carmelo Vicente"; Username = "carmelo.vicente"; Password = "Password123!"; OU = "Transportes" },
    @{ Name = "Luis Lago"; Username = "luis.lago"; Password = "Password123!"; OU = "Transportes" },
    @{ Name = "Maria Molina"; Username = "maria.molina"; Password = "Password123!"; OU = "Almacén" },
    @{ Name = "Elena Martínez"; Username = "elena.martinez"; Password = "Password123!"; OU = "Almacén" },
    @{ Name = "Ruben Centeno"; Username = "ruben.centeno"; Password = "Password123!"; OU = "Almacén" },
    @{ Name = "Carlos Costas"; Username = "carlos.costas"; Password = "Password123!"; OU = "Desarrollos" },
    @{ Name = "Lucia Silva"; Username = "lucia.silva"; Password = "Password123!"; OU = "Desarrollos" },
    @{ Name = "Roberto Leal"; Username = "roberto.leal"; Password = "Password123!"; OU = "Sistemas" }
)

foreach ($user in $userList) {
    $userDistinguishedName = "CN=$($user.Username),OU=$($user.OU),$domain"
    if (-not (Get-ADUser -Filter "DistinguishedName -eq '$userDistinguishedName'" -ErrorAction SilentlyContinue)) {
        $securePassword = ConvertTo-SecureString $user.Password -AsPlainText -Force
        New-ADUser -Name $user.Name -UserPrincipalName "$($user.Username)@$domain" `
                   -SamAccountName $user.Username -AccountPassword $securePassword `
                   -PasswordNeverExpires $true -Path "OU=$($user.OU),$domain" -Enabled $true
        Write-Host "Usuario '$($user.Name)' creado en la OU '$($user.OU)'."
    } else {
        Write-Host "El usuario '$($user.Name)' ya existe."
    }
}

Write-Host "Todas las OUs y usuarios han sido creados correctamente."
