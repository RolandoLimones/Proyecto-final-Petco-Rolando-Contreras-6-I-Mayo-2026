// ============================================================
//  agenterepositorio.dart
//  Agente interactivo para gestionar repositorios de GitHub.
//
//  Uso:
//    dart agenterepositorio.dart
//
//  Funcionalidades:
//    1. Verificar / inicializar git en el proyecto
//    2. Configurar o cambiar el repositorio remoto (origin)
//    3. Elegir la rama (main por defecto u otra)
//    4. Escribir el mensaje de commit
//    5. Hacer add + commit + push automáticamente
//    6. Menú para operaciones repetidas
//
//  Requiere: git instalado en el sistema.
//  Compatible con cualquier proyecto Dart / Flutter.
// ============================================================

import 'dart:io';

// ─── Colores ANSI para la terminal ────────────────────────────
const String _reset  = '\x1B[0m';
const String _bold   = '\x1B[1m';
const String _red    = '\x1B[31m';
const String _green  = '\x1B[32m';
const String _yellow = '\x1B[33m';
const String _cyan   = '\x1B[36m';
const String _magenta= '\x1B[35m';
const String _white  = '\x1B[97m';

// ─── Helpers de impresión ──────────────────────────────────────
void _titulo(String msg)  => print('\n$_bold$_cyan$msg$_reset');
void _ok(String msg)      => print('$_green  ✔  $msg$_reset');
void _error(String msg)   => print('$_red  ✖  $msg$_reset');
void _info(String msg)    => print('$_yellow  ➜  $msg$_reset');
void _pregunta(String msg)=> stdout.write('$_magenta  ?  $_white$_bold$msg$_reset ');
void _separador()         => print('$_cyan${'─' * 52}$_reset');

// ─── Leer línea del usuario ────────────────────────────────────
String _leer({String porDefecto = ''}) {
  final entrada = stdin.readLineSync()?.trim() ?? '';
  return entrada.isEmpty ? porDefecto : entrada;
}

// ─── Ejecutar un comando git ───────────────────────────────────
Future<({int codigo, String salida, String error})> _git(
  List<String> args, {
  String? directorio,
}) async {
  final resultado = await Process.run(
    'git',
    args,
    workingDirectory: directorio ?? Directory.current.path,
    runInShell: true,
  );
  return (
    codigo: resultado.exitCode,
    salida: resultado.stdout.toString().trim(),
    error:  resultado.stderr.toString().trim(),
  );
}

// ─── Verificar que git esté instalado ─────────────────────────
Future<bool> _verificarGit() async {
  final r = await _git(['--version']);
  if (r.codigo == 0) {
    _ok('Git detectado: ${r.salida}');
    return true;
  }
  _error('Git no está instalado o no está en el PATH.');
  _info('Descárgalo en: https://git-scm.com/downloads');
  return false;
}

// ─── Verificar / inicializar repositorio git ──────────────────
Future<bool> _inicializarRepo(String ruta) async {
  final gitDir = Directory('$ruta/.git');
  if (gitDir.existsSync()) {
    _ok('Repositorio git ya inicializado.');
    return true;
  }
  _info('Inicializando repositorio git...');
  final r = await _git(['init'], directorio: ruta);
  if (r.codigo == 0) {
    _ok('Repositorio inicializado correctamente.');
    return true;
  }
  _error('No se pudo inicializar git: ${r.error}');
  return false;
}

// ─── Obtener remote actual ────────────────────────────────────
Future<String?> _obtenerRemote(String ruta) async {
  final r = await _git(['remote', 'get-url', 'origin'], directorio: ruta);
  if (r.codigo == 0) return r.salida;
  return null;
}

// ─── Configurar remote origin ─────────────────────────────────
Future<bool> _configurarRemote(String url, String ruta) async {
  // Eliminar si ya existe
  final existe = await _obtenerRemote(ruta);
  if (existe != null) {
    await _git(['remote', 'remove', 'origin'], directorio: ruta);
  }
  final r = await _git(['remote', 'add', 'origin', url], directorio: ruta);
  if (r.codigo == 0) {
    _ok('Remote "origin" configurado: $url');
    return true;
  }
  _error('Error al configurar remote: ${r.error}');
  return false;
}

// ─── Verificar si hay cambios sin commitear ───────────────────
Future<bool> _hayCambios(String ruta) async {
  final r = await _git(['status', '--porcelain'], directorio: ruta);
  return r.salida.isNotEmpty;
}

// ─── Obtener rama actual ──────────────────────────────────────
Future<String> _ramaActual(String ruta) async {
  final r = await _git(['branch', '--show-current'], directorio: ruta);
  if (r.codigo == 0 && r.salida.isNotEmpty) return r.salida;
  return 'main';
}

// ─── Crear / cambiar a una rama ───────────────────────────────
Future<bool> _cambiarRama(String rama, String ruta) async {
  // Verificar si la rama ya existe
  final existe = await _git(
    ['branch', '--list', rama],
    directorio: ruta,
  );

  ProcessResult resultado;
  if (existe.salida.isNotEmpty) {
    // La rama ya existe localmente → solo cambiar
    resultado = await Process.run(
      'git', ['checkout', rama],
      workingDirectory: ruta, runInShell: true,
    );
  } else {
    // Crear y cambiar a la nueva rama
    resultado = await Process.run(
      'git', ['checkout', '-b', rama],
      workingDirectory: ruta, runInShell: true,
    );
  }

  if (resultado.exitCode == 0) {
    _ok('Rama activa: $rama');
    return true;
  }
  _error('Error al cambiar de rama: ${resultado.stderr}');
  return false;
}

// ─── Hacer git add, commit y push ─────────────────────────────
Future<void> _addCommitPush({
  required String commit,
  required String rama,
  required String ruta,
}) async {
  // 1. git add .
  _info('Agregando archivos (git add .)...');
  final addR = await _git(['add', '.'], directorio: ruta);
  if (addR.codigo != 0) {
    _error('Error en git add: ${addR.error}');
    return;
  }
  _ok('Archivos agregados.');

  // 2. git commit
  _info('Creando commit: "$commit"');
  final commitR = await _git(
    ['commit', '-m', commit],
    directorio: ruta,
  );
  if (commitR.codigo != 0) {
    // Puede ser que no haya cambios
    if (commitR.error.contains('nothing to commit') ||
        commitR.salida.contains('nothing to commit')) {
      _info('No hay cambios nuevos para commitear.');
    } else {
      _error('Error en commit: ${commitR.error.isNotEmpty ? commitR.error : commitR.salida}');
    }
    return;
  }
  _ok('Commit creado correctamente.');

  // 3. git push
  _info('Subiendo cambios a GitHub (rama: $rama)...');
  // --set-upstream para crear la rama remota si no existe
  final pushR = await _git(
    ['push', '--set-upstream', 'origin', rama],
    directorio: ruta,
  );
  if (pushR.codigo == 0) {
    _ok('¡Cambios subidos exitosamente a la rama "$rama"!');
    if (pushR.salida.isNotEmpty) print('   ${pushR.salida}');
  } else {
    _error('Error al hacer push:\n${pushR.error}');
    _info('Asegúrate de haber autenticado git con tu cuenta de GitHub.');
    _info('Usa: gh auth login  o configura un token PAT.');
  }
}

// ─── Mostrar estado del repositorio ───────────────────────────
Future<void> _mostrarEstado(String ruta) async {
  _titulo('📊 Estado actual del repositorio');
  final statusR = await _git(['status', '--short'], directorio: ruta);
  if (statusR.salida.isEmpty) {
    _ok('Sin cambios pendientes. El directorio está limpio.');
  } else {
    print(statusR.salida);
  }

  final logR = await _git(
    ['log', '--oneline', '-5'],
    directorio: ruta,
  );
  if (logR.codigo == 0 && logR.salida.isNotEmpty) {
    _titulo('📝 Últimos 5 commits:');
    for (final linea in logR.salida.split('\n')) {
      print('   $_yellow$linea$_reset');
    }
  }
}

// ─── Menú principal ───────────────────────────────────────────
Future<void> _menuPrincipal(String ruta) async {
  bool continuar = true;

  while (continuar) {
    _titulo('╔══════════════════════════════════════════╗');
    _titulo('║   🚀  AGENTE REPOSITORIO GITHUB          ║');
    _titulo('╚══════════════════════════════════════════╝');
    print('$_white  Directorio: $_yellow$ruta$_reset');
    _separador();
    // Mostrar usuario actual
    final usuarioActual = await _git(['config', 'user.name']);
    final emailActual   = await _git(['config', 'user.email']);
    final sesionInfo = usuarioActual.salida.isNotEmpty
        ? '$_green${usuarioActual.salida}$_reset <${emailActual.salida}>'
        : '${_red}Sin sesión configurada$_reset';
    print('$_white  Sesión:   $sesionInfo');
    _separador();
    print('$_white  [1] $_cyan Commit y Push (subir cambios)');
    print('$_white  [2] $_cyan Cambiar remote (URL de GitHub)');
    print('$_white  [3] $_cyan Ver estado del repositorio');
    print('$_white  [4] $_cyan Cambiar de rama');
    print('$_white  [5] $_cyan Ver ramas disponibles');
    print('$_white  [6] $_cyan Pull (descargar últimos cambios)');
    print('$_white  [7] $_yellow Cerrar sesión (borrar usuario/correo)');
    print('$_white  [0] $_red  Salir$_reset');
    _separador();

    _pregunta('Elige una opción:');
    final opcion = _leer(porDefecto: '0');

    switch (opcion) {
      // ── Commit + Push ────────────────────────────────────────
      case '1':
        _titulo('📤 Commit y Push');

        final remoteActual = await _obtenerRemote(ruta);
        if (remoteActual == null) {
          _info('No hay remote configurado. Ingresa la URL de GitHub:');
          _pregunta('URL (https://github.com/usuario/repo.git):');
          final url = _leer();
          if (url.isEmpty) { _error('URL vacía. Operación cancelada.'); break; }
          final ok = await _configurarRemote(url, ruta);
          if (!ok) break;
        } else {
          _info('Remote actual: $remoteActual');
          _pregunta('¿Cambiar URL? (Enter para mantener / nueva URL):');
          final nuevaUrl = _leer();
          if (nuevaUrl.isNotEmpty) {
            await _configurarRemote(nuevaUrl, ruta);
          }
        }

        final ramaAct = await _ramaActual(ruta);
        _info('Rama actual: $ramaAct');
        _pregunta('Rama destino (Enter = "$ramaAct" / escribe otra):');
        final ramaElegida = _leer(porDefecto: ramaAct);

        if (ramaElegida != ramaAct) {
          final cambiado = await _cambiarRama(ramaElegida, ruta);
          if (!cambiado) break;
        }

        _pregunta('Mensaje del commit:');
        final commit = _leer(porDefecto: 'actualización del proyecto');

        await _addCommitPush(
          commit: commit,
          rama:   ramaElegida,
          ruta:   ruta,
        );
        break;

      // ── Cambiar remote ───────────────────────────────────────
      case '2':
        _titulo('🔗 Configurar Remote (origin)');
        final actual = await _obtenerRemote(ruta);
        if (actual != null) _info('URL actual: $actual');
        _pregunta('Nueva URL de GitHub (https://github.com/usuario/repo.git):');
        final url = _leer();
        if (url.isEmpty) { _error('URL vacía. Cancelado.'); break; }
        await _configurarRemote(url, ruta);
        break;

      // ── Estado ───────────────────────────────────────────────
      case '3':
        await _mostrarEstado(ruta);
        break;

      // ── Cambiar rama ─────────────────────────────────────────
      case '4':
        _titulo('🌿 Cambiar de Rama');
        final ramaAct = await _ramaActual(ruta);
        _info('Rama actual: $ramaAct');
        _pregunta('Nombre de la rama (nueva o existente):');
        final rama = _leer();
        if (rama.isEmpty) { _error('Nombre vacío. Cancelado.'); break; }
        await _cambiarRama(rama, ruta);
        break;

      // ── Ver ramas ────────────────────────────────────────────
      case '5':
        _titulo('🌿 Ramas disponibles');
        final r = await _git(['branch', '-a'], directorio: ruta);
        if (r.salida.isEmpty) {
          _info('No hay ramas aún. Realiza el primer commit.');
        } else {
          for (final linea in r.salida.split('\n')) {
            final esActual = linea.startsWith('*');
            print(esActual
                ? '$_green  $linea$_reset'
                : '$_white  $linea$_reset');
          }
        }
        break;

      // ── Pull ─────────────────────────────────────────────────
      case '6':
        _titulo('📥 Pull — Descargar cambios remotos');
        final ramaAct = await _ramaActual(ruta);
        _info('Descargando cambios de origin/$ramaAct...');
        final r = await _git(['pull', 'origin', ramaAct], directorio: ruta);
        if (r.codigo == 0) {
          _ok(r.salida.isNotEmpty ? r.salida : 'Repositorio actualizado.');
        } else {
          _error('Error en pull: ${r.error}');
        }
        break;

      // ── Cerrar sesión ─────────────────────────────────────
      case '7':
        await _cerrarSesion();
        break;

      // ── Salir ────────────────────────────────────────────
      case '0':
        continuar = false;
        _titulo('👋 ¡Hasta pronto!');
        break;

      default:
        _error('Opción no válida. Elige entre 0 y 7.');
    }

    if (continuar) {
      _separador();
      _pregunta('Presiona Enter para continuar...');
      stdin.readLineSync();
    }
  }
}

// ─── Cerrar sesión: borra nombre y correo de git config ──────
Future<void> _cerrarSesion() async {
  _titulo('🔓 Cerrar Sesión de Git');

  // Mostrar datos actuales
  final nombreLocal  = await _git(['config', '--local',  'user.name']);
  final emailLocal   = await _git(['config', '--local',  'user.email']);
  final nombreGlobal = await _git(['config', '--global', 'user.name']);
  final emailGlobal  = await _git(['config', '--global', 'user.email']);

  _info('Configuración local  → nombre: "${nombreLocal.salida}"  email: "${emailLocal.salida}"');
  _info('Configuración global → nombre: "${nombreGlobal.salida}"  email: "${emailGlobal.salida}"');

  _pregunta('¿Qué deseas borrar? [1] Solo local  [2] Solo global  [3] Ambas  [0] Cancelar:');
  final opcion = _leer(porDefecto: '0');

  if (opcion == '0') {
    _info('Operación cancelada.');
    return;
  }

  bool borroAlgo = false;

  // ── Borrar local ──────────────────────────────────────────────
  if (opcion == '1' || opcion == '3') {
    final rLocal1 = await _git(['config', '--local', '--unset', 'user.name']);
    final rLocal2 = await _git(['config', '--local', '--unset', 'user.email']);
    if (rLocal1.codigo == 0 || rLocal1.salida.isEmpty) {
      if (nombreLocal.salida.isNotEmpty) {
        _ok('Nombre local eliminado.');
        borroAlgo = true;
      } else {
        _info('No había nombre local configurado.');
      }
    } else {
      _info('No había nombre local configurado.');
    }
    if (rLocal2.codigo == 0 || rLocal2.salida.isEmpty) {
      if (emailLocal.salida.isNotEmpty) {
        _ok('Email local eliminado.');
        borroAlgo = true;
      } else {
        _info('No había email local configurado.');
      }
    } else {
      _info('No había email local configurado.');
    }
  }

  // ── Borrar global ─────────────────────────────────────────────
  if (opcion == '2' || opcion == '3') {
    _pregunta('⚠ Esto borrará tu usuario/correo global de git. ¿Confirmas? (s/n):');
    final confirma = _leer(porDefecto: 'n').toLowerCase();
    if (confirma != 's') {
      _info('Borrado global cancelado.');
    } else {
      final rGlob1 = await _git(['config', '--global', '--unset', 'user.name']);
      final rGlob2 = await _git(['config', '--global', '--unset', 'user.email']);
      if (rGlob1.codigo == 0) { _ok('Nombre global eliminado.'); borroAlgo = true; }
      else { _info('No había nombre global / ya estaba vacío.'); }
      if (rGlob2.codigo == 0) { _ok('Email global eliminado.');  borroAlgo = true; }
      else { _info('No había email global / ya estaba vacío.'); }
    }
  }

  if (borroAlgo) {
    _ok('Sesión cerrada. La próxima vez que ejecutes el agente se te pedirán los datos nuevamente.');
  } else {
    _info('No se realizaron cambios.');
  }
}

// ─── MAIN ─────────────────────────────────────────────────────
Future<void> main(List<String> args) async {
  // Limpiar pantalla
  if (Platform.isWindows) {
    await Process.run('cls', [], runInShell: true);
  } else {
    stdout.write('\x1B[2J\x1B[H');
  }

  _titulo('╔══════════════════════════════════════════╗');
  _titulo('║   🚀  AGENTE REPOSITORIO GITHUB          ║');
  _titulo('║   Dart · Interactivo · Reutilizable      ║');
  _titulo('╚══════════════════════════════════════════╝');
  _separador();

  // 1. Verificar git
  final gitOk = await _verificarGit();
  if (!gitOk) exit(1);

  // 2. Confirmar / elegir directorio del proyecto
  final dirActual = Directory.current.path;
  _info('Directorio actual: $dirActual');
  _pregunta('¿Usar este directorio? (Enter = Sí / escribe otra ruta):');
  final rutaInput = _leer();
  final ruta = rutaInput.isEmpty ? dirActual : rutaInput;

  // Verificar que la ruta existe
  if (!Directory(ruta).existsSync()) {
    _error('La ruta "$ruta" no existe.');
    exit(1);
  }

  // 3. Inicializar git si no existe
  final initOk = await _inicializarRepo(ruta);
  if (!initOk) exit(1);

  // 4. Configurar e-mail y nombre de git (si no están configurados)
  final nombreR = await _git(['config', 'user.name']);
  if (nombreR.salida.isEmpty) {
    _pregunta('Nombre para git config (usuario GitHub):');
    final nombre = _leer(porDefecto: 'Usuario');
    await _git(['config', 'user.name', nombre], directorio: ruta);
  }

  final emailR = await _git(['config', 'user.email']);
  if (emailR.salida.isEmpty) {
    _pregunta('Email para git config:');
    final email = _leer(porDefecto: 'usuario@correo.com');
    await _git(['config', 'user.email', email], directorio: ruta);
  }

  // 5. Mostrar rama actual
  final rama = await _ramaActual(ruta);
  if (rama.isEmpty || rama == 'HEAD') {
    // Primera vez: establecer rama main
    await _git(['checkout', '-b', 'main'], directorio: ruta);
    _ok('Rama principal establecida: main');
  } else {
    _ok('Rama actual: $rama');
  }

  // 6. Menú principal
  await _menuPrincipal(ruta);
}
